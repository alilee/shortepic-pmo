# == Schema Information
# Schema version: 12
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
#  res_idx_fti           :tsvector      
#

class Role < Item
  has_one :detail, :class_name => 'RoleDetail'
  
  has_many :role_placements, :dependent => :destroy, :order => 'end_on, start_on'
  has_many :cr_effort_lines, :include => [:milestone, :change_request], :dependent => :destroy
  has_many :timesheet_lines, :include => [:timesheet, :milestone], :dependent => :destroy
  has_many :items
  
  def current_role_placements
    RolePlacement.find_all_by_role_id(id, :include => :person, :conditions => 'now() between start_on and end_on', :order => 'committed_hours DESC')
  end
  
  def approved_effort_lines
    CrEffortLine.find_all_by_role_id(id, 
      :include => [:milestone, {:change_request => :status}], 
      :conditions => ["generic_stage = ?", Status::COMPLETE], 
      :order => 'hours DESC')
  end
  
  def total_hours_budget
    approved_effort_lines.inject(0) {|sum, l| sum + l.hours }
  end
  
  # TODO: C - Remove deprecated
  def depr_actuals_to_date
    connection.select_all("
      SELECT 
        p.id AS person_id,
        p.title AS person_title, 
        ms.id AS milestone_id, 
        ms.title AS milestone_title, 
        sum(tl.normal_hours) AS normal_hours, 
        sum(tl.overtime_hours) AS overtime_hours, 
        sum(tl.uncharged_hours) AS uncharged_hours
      FROM
        items p, items ms, items ts, timesheet_lines tl, statuses st, timesheet_details dt
      WHERE
        tl.timesheet_id = ts.id
        AND ts.id = dt.timesheet_id
        AND dt.person_id_worker = p.id
        AND ts.status_id = st.id
        AND st.generic_stage = '#{Status::COMPLETE}'
        AND tl.milestone_id = ms.id
        AND tl.role_id = #{id}
      GROUP BY 
        p.id, p.title, ms.id, ms.title
      ORDER BY
        normal_hours DESC"
     )
  end
  
  # TODO: B - Need to test Role.actuals_to_date
  def actuals_to_date
    tl = TimesheetLine.find_by_sql(["
      SELECT
        td.person_id_worker as person_id,
        p.title as person_title,
        tl.milestone_id as milestone_id,
        m.title as milestone_title,
        sum(tl.normal_hours) as normal_hours,
        sum(tl.overtime_hours) as overtime_hours,
        sum(tl.uncharged_hours) as uncharged_hours
      FROM
        timesheet_lines tl, timesheet_details td, items i, items p, items m, statuses s
      WHERE
         tl.timesheet_id = td.timesheet_id
         AND tl.timesheet_id = i.id
         AND td.person_id_worker = p.id
         AND tl.milestone_id = m.id
         AND tl.role_id = ?
         AND i.status_id = s.id and s.generic_stage = ?
      GROUP BY
        person_id_worker, p.title, tl.milestone_id, m.title",
    id, Status::COMPLETE])
  end
  
  # Return the ids of the roles reporting this role and their sub-roles.
  # FIXME: A - should this be role_child_ids
  def role_descendant_ids(status_filter)
    Role.find_all_by_role_id(id, 
      :include => :status,
      :conditions => ['generic_stage in (?)', status_filter]
    ).collect { |r| r.id }
  end
  
  # Recursively find all the roles which ultimately report to this role.
  def descendant_role_ids
    roles = Role.find_all_by_role_id(id)
    result = roles.collect {|r| r.id}
    #roles.each do |r|
    #  result.concat(r.descendant_role_ids) 
    #end
    result
  end

end
