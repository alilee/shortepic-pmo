# == Schema Information
# Schema version: 16
#
# Table name: items
#
#  id                    :integer       not null, primary key
#  type                  :string(255)   not null
#  title                 :string(255)   not null
#  project_id            :integer       
#  role_id               :integer       not null
#  person_id             :integer       not null
#  status_id             :integer       not null
#  code_id_priority      :integer       not null
#  project_id_escalation :integer       
#  description           :text          
#  due_on                :date          
#  lft                   :integer       
#  rgt                   :integer       
#  updated_at            :datetime      not null
#  person_id_updated_by  :integer       not null
#  version               :integer       
#  res_idx_fti           :string        
#

# TODO: C - use acts_as_nested_set
require 'pp'

class Project < Item
  #include SymetrieCom
  
  has_one :detail, :class_name => 'ProjectDetail'
  
  ISSUE_PARAMS = {:include => :priority_code, :order => 'value, status_id'}
  
  # Potentially many items will point to a project in the project_id_escalation field.
  has_many :escalated_items, :class_name => 'Item', :foreign_key => 'project_id_escalation'
  has_many :issues, ISSUE_PARAMS
  
  has_many :child_roles, :class_name => 'Role', :foreign_key => 'project_id'

  # TODO: C - remove Lft and Rgt from history
  acts_as_nested_set :parent_column => 'project_id'

  # TODO: B - need to make sure all possible failures for better nested set are validated.
  validate :project_validations
      
  # Retrieve the last updates status report that has been marked as being complete.
  def latest_complete_status_report
    StatusReport.find(:first, :include => [:detail, :status], :conditions => ['project_id = ? and generic_stage = ?', id, Status::COMPLETE], :order => 'period_ending_on DESC')
  end

  # Ids of this project's ancestors
  #
  # TODO: C - performance using nested set
  def ancestor_ids
    result = ancestors.collect { |p| p.id }
  end
  
  # TODO: C - use nested set
  def self_and_ancestor_ids
    result = self_and_ancestors.collect { |p| p.id }
  end
    
  # Returns whether this project is an ancestor of the given item.
  def ancestor_of?(item)
    return false if item.nil? 
    
    item_parent_id = item.project_id
    return true if self.id == item_parent_id

    item_parent = item.parent
    return parent.lft >= self.lft && parent.rgt <= self.rgt
  end

  def children_by_class(class_obj, status_filter = nil)
    if status_filter
      class_obj.find_all_by_project_id(id, :include => :status, :conditions => ['generic_stage in (?)', status_filter], :order => 'title')
    else
      class_obj.find_all_by_project_id(id, :order => 'title')
    end
  end
  
  def children_ids_by_class(class_obj)
    children_by_class(class_obj).collect { |x| x.id }
  end
 
  # Returns the projects which are descendants of self 
  def descendant_projects
    all_children
  end
  
  # TODO: C - performance with nested set
  def descendant_project_ids
    descendant_projects.collect { |p| p.id }
  end
  
  # ids of this and all descendant projects, filtered for status.
  def self_and_descendant_project_ids(status_filter = nil)
    Project.find(:all,
      :include => :status,
      :conditions => ['lft >= ? and rgt <= ? and (1 = ? or generic_stage in (?))', lft, rgt, status_filter.nil? ? 1 : 0, status_filter || [1]]
    ).collect { |p| p.id }
  end

  def descendants_by_class(class_obj, options = {})
    Item.find_all_by_project_id_and_type(descendant_project_ids << id, class_obj.name, options)
  end
  
  def descendant_ids_by_class(class_obj)
    descendants_by_class(class_obj).collect { |x| x.id }
  end
  
  def pending_change_requests
    project_down_ids = descendant_project_ids << id
    @crs = ChangeRequest.find_all_by_project_id(project_down_ids, :include => [:status, :priority_code, :effort_lines], 
            :conditions => ['generic_stage in (?)', Status.incomplete], :order => 'codes.value', :limit => 5)
  end
    
  # TODO: C - should this be called key milestones?
  def pending_milestones
    project_down_ids = descendant_project_ids << id
    project_up_ids = ancestor_ids << id
    @milestones = Milestone.find_all_by_project_id_and_project_id_escalation(
      project_down_ids, project_up_ids, 
      :include => [:priority_code, :status], 
      :conditions => ['generic_stage in (?)', Status.in_progress], 
      :order => 'codes.value, title', 
      :limit => 5)
  end
  
  def key_issues
    # issues summary
    project_down_ids = descendant_project_ids << id
    project_up_ids = ancestor_ids << id
    Issue.find_all_by_project_id_and_project_id_escalation(
      project_down_ids, project_up_ids, 
      :include => [:priority_code, :status],
      :conditions => ['generic_stage in (?)', Status.in_progress], 
      :order => 'codes.value, due_on, title',
      :limit => 5)    
  end
  
  # All issues under this project escalated above this project, which are not closed.
  def escalated_issues
    return [] if parent.nil?
    Issue.find_all_by_project_id_and_project_id_escalation(descendant_project_ids << id, ancestor_ids,
      :include => [:status, :priority_code],
      :conditions => ['generic_stage in (?)', Status.incomplete],
      :order => 'codes.value, due_on')
  end
  
  # Codification of escalation - keep as useful reference even if copies are made for specialisation
  def escalated_by_class(class_obj, status_filter = nil, order = 'title', limit = nil)
    project_down_ids = descendant_project_ids << id
    project_up_ids = ancestor_ids << id
    class_name_filter = class_obj.name
    find_options = Hash.new
    find_options[:order] = order
    find_options[:include] = [:priority_code]
    find_options[:include] << :status unless status_filter.nil?
    find_options[:limit] = limit
    find_options[:conditions] = ['generic_stage in (?)', status_filter] unless status_filter.nil?
    class_obj.find_all_by_project_id_and_project_id_escalation_and_type(
      project_down_ids, 
      project_up_ids, 
      class_name_filter,
      find_options
    )
  end
  
  # All issues under this project not yet escalated above this project, which are not closed.
  def not_escalated_issues
    Issue.find_all_by_project_id_and_project_id_escalation(descendant_project_ids << id, id,
      :include => [:status, :priority_code],
      :conditions => ['generic_stage in (?)', Status.incomplete],
      :order => 'codes.value, due_on')
  end

  def associated_issues
    link_ids = Array.new
    Association.find(:all, :conditions => ['item_id_from = ?', id]).each { |a|
      link_ids.push(a.item_id_to)
    }
    Association.find(:all, :conditions => ['item_id_to = ?', id]).each { |a|
      link_ids.push(a.item_id_from)
    }
    link_ids.empty? ? [] : Issue.find_all_by_id(link_ids, ISSUE_PARAMS)
  end

  # Total budget and actual hours by milestone 
  def milestone_costs
    desc_proj_ids = descendant_project_ids << self.id
    Milestone.find_by_sql(["
    SELECT
      m.title as milestone_title,
      m.project_id_escalation,
      p.id as project_id,
      p.title as project_title,
      actual_lines.actual_hours as actual_hours,
      actual_lines.actual_effort as actual_effort,
      expense_lines.expense_budget as expense_budget,
      sum(cr.effort_budget) as effort_budget,
      sum(cr.hours) as budget_hours
    FROM
      items p,
      items m left outer join cr_effort_lines cr on m.id = cr.milestone_id,
      (SELECT
        m.id as id,
        sum(e.expense_budget) as expense_budget
      FROM
        items m left outer join cr_expense_lines e on m.id = e.milestone_id
      WHERE
        m.type = 'Milestone' AND
        m.project_id in (?)
      GROUP BY
        m.id) as expense_lines,
        (SELECT
          m.id as id,
          (sum(normal_hours) + sum(overtime_hours)) as actual_hours,
          (sum(tl.normal_hours * r.normal_hourly_rate) + sum(tl.overtime_hours * r.overtime_hourly_rate)) as actual_effort
        FROM
          timesheet_lines tl right outer join items m on tl.milestone_id = m.id
          left outer join timesheet_details td on tl.timesheet_id = td.timesheet_id
          left outer join role_placements r on tl.role_id = r.role_id and
          td.person_id_worker = r.person_id and
          tl.worked_on between r.start_on and r.end_on
        WHERE
          m.type = 'Milestone' AND
          m.project_id in (?)
        GROUP BY
          m.id) as actual_lines
    WHERE
      m.type = 'Milestone' AND
      p.type = 'Project' AND
      p.id = m.project_id AND
      m.id = expense_lines.id AND
      m.id = actual_lines.id AND
      m.project_id in (?)
    GROUP BY
      m.title, m.project_id_escalation, p.id, p.title, expense_budget, actual_hours, actual_effort
    ORDER BY
      p.title, m.title",
    desc_proj_ids, desc_proj_ids, desc_proj_ids]) 
  end
  
  def escalation_point_to_project(item_id, project_up_ids = nil)
    # something in project_id which should be a descendant project reaches us by escalation how?
    if !project_up_ids
      project_up_ids = ancestor_ids << id
    end
    project = Item.find(item_id)
    project = Project.find(project.project_id) until project_up_ids.include?(project.project_id_escalation)
    project
  end
  
  def completed_deliverables
    # library view
    Milestone.find_all_by_project_id(id,
      :include => [:attachments, :status],
      :conditions => ['generic_stage = ?
                       and attachments.version = (SELECT max(a.version)
                                                  FROM attachments a
                                                  WHERE a.item_id = attachments.item_id
                                                  AND a.filename = attachments.filename)',
                       Status::COMPLETE],
      :order => 'title, filename')    
  end
  
  def review_deliverables
    # library view
    Milestone.find_all_by_project_id(id,
      :include => [:attachments, :status],
      :conditions => ['generic_stage = ?
                       and attachments.version = (SELECT max(a.version)
                                                  FROM attachments a
                                                  WHERE a.item_id = attachments.item_id
                                                  AND a.filename = attachments.filename)',
                       Status::REVIEW],
      :order => 'title, filename')    
  end
  
  def formative_roles
    Role.find_all_by_project_id_and_project_id_escalation(descendant_project_ids << id, ancestor_ids << id,
      :include => [:status, :priority_code],
      :conditions => ['generic_stage in (?)', Status.formative],
      :order => 'generic_stage, statuses.value, codes.value, due_on, title')
  end

  def incomplete_resources
    Person.find_all_by_project_id_and_project_id_escalation(descendant_project_ids << id, ancestor_ids << id,
      :include => [:status],
      :conditions => ['generic_stage in (?)', Status.formative],
      :order => 'generic_stage, value')
  end

  def incomplete_role_placements
    RolePlacement.find_by_sql(["
      SELECT
        r.id as role_id,
        r.title as role_title,
        p.id as person_id,
        p.title as person_title,
        sum(rp.committed_hours) as committed_hours,
        sum(tl.normal_hours) as normal_hours,
        sum(tl.overtime_hours) as overtime_hours
      FROM
        role_placements rp,
        items p,
        items r,
        timesheet_details td,
        timesheet_lines tl,
        statuses s
      WHERE
        rp.person_id = p.id AND
        rp.role_id = r.id AND
        r.status_id = s.id AND
        tl.role_id = rp.role_id AND
        td.person_id_worker = rp.person_id AND
        td.timesheet_id = tl.timesheet_id AND
        r.project_id in (?) AND
        r.project_id_escalation in (?) AND
        s.generic_stage in (?)
      GROUP BY
        r.id, r.title, p.id, p.title
      ORDER BY r.title, p.title",
    descendant_project_ids << id, ancestor_ids << id, Status.incomplete])
  end
  
  # Return the key incomplete absences
  #
  # Top five absences which are not yet complete by priority and then due date
  def key_absences
    Absences.find_all_by_status_and_project_id
  end
  
  #
  # Generate a table of levels of objects at each status on each day.
  # Excludes those which end up cancelled
  #
  # burndown[status_id][Date.today] means the number of items of that status (or earlier by sequence) as at today
  #
  def burndown(type_name)
    deltas = Hash.new
    status_ids = Status.find_all_by_type_name(type_name, :order => 'sequence, value').collect {|s| s.id }
    # exclude cancelled
    project_ids = self_and_descendant_project_ids
    items = Item.find_all_by_type(type_name, :include => :status, :conditions => ["generic_stage <> ? and project_id in (?)", Status::WITHDRAWN, project_ids])
    
    items.each do |i|
      puts "considering item: #{i.title}"
      last_status_id = 0
      weight = block_given? ? yield(i) : 1
      i.versions.each do |v|
        puts "considering version: #{v.version}"
        if v.version == 1 then
          puts "first version"
          status_ids.each do |s|
            puts "updating for index: #{s}"
            deltas[s] ||= Hash.new
            deltas[s][v.updated_at.to_date] ||= 0
            deltas[s][v.updated_at.to_date] += weight
            pp deltas[s][v.updated_at.to_date]
          end
          last_status_id = status_ids.first
          pp deltas
        end
        
        puts "bringing forward"
        last_status_order = status_ids.index(last_status_id)
        current_status_order = status_ids.index(v.status_id)
        increment = -1 if last_status_order < current_status_order # moved forward
        increment = +1 if last_status_order > current_status_order # moved backward   
        puts "last...current index: #{last_status_order}...#{current_status_order}"       
        (last_status_order...current_status_order).each do |i|
          puts "adjusting for #{i}"
          deltas[status_ids[i]][v.updated_at.to_date] ||= 0
          deltas[status_ids[i]][v.updated_at.to_date] += increment * weight
        end
        last_status_id = v.status_id   
        pp deltas
      end
    end
    
    # generate cumulative from deltas
    cumulative = Hash.new
    result = Hash.new
    deltas.each_pair do |delta_status_id,delta_date_series|
      result[delta_status_id] ||= Hash.new
      cumulative[delta_status_id] ||= 0
      dates = delta_date_series.keys.sort
      increment = 0
      dates.each do |date|
        increment = delta_date_series[date]
        cumulative[delta_status_id] += increment
        result[delta_status_id][date] = cumulative[delta_status_id]
      end
    end 
    # carry the lines out to today
    cumulative.each_pair do |status_id, effort|
      result[status_id][Date.today] = effort
    end
    result
  
  end
  
  protected
  
  def project_validations
      if descendant_project_ids.include?(project_id)
          errors.add("project_id", "cannot be a child of one of its descendants")
      end
  end
end
