# TODO: B - status report tracking view
class ProjectController < ItemController
      
  def operations
    if item_from_id.nil?
      # use the person's project, but probably should be:
      # TODO: C - the project highest in the tree, of those projects the user has current assignments on
      redirect_to :id => session[:person].project_id
      return
    end
    
    @last_complete_status_report = @project.latest_complete_status_report
    @child_projects = @project.escalated_by_class(Project, Status.in_progress, 'lft')
    @key_issues = @project.key_issues
    @pending_milestones = @project.pending_milestones
    @pending_change_requests = @project.pending_change_requests
    @absences = @project.escalated_by_class(Absence, Status.incomplete, 'codes.value, due_on', 5)    
    @page_title = @project.title
  end  
  
  # View of all milestones
  def plan
    @milestones = @project.escalated_by_class(Milestone, Status.in_progress, 'codes.value, due_on')
  end

  def issues
    @page_title = @project.title
    
    @escalated_issues = @project.escalated_issues
    @not_escalated_issues = @project.not_escalated_issues
  end

  def risks
    @page_title = @project.title
    
    @risks = @project.escalated_by_class(Risk, Status.in_progress, 'statuses.generic_stage, statuses.value, codes.value, due_on')
  end
  
  # TODO: A - financial view
  def financials
    raise NotImplementedError.new
    project_down_ids = @project.descendant_project_ids << @project.id

    @cost_lines = Milestone.find_by_sql("
      select m.id as id, 
             m.title as title, 
             ra.id as role_id, 
             ra.title as role_title, 
             sum(tl.normal_hours+tl.overtime_hours) as actual_hours, 
             budget_lines.budget
        from items m left outer join timesheet_lines tl on m.id = tl.milestone_id,
             items ra,
            (select m.id as id, sum(e.hours) as budget
               from items m left outer join cr_effort_lines e on m.id = e.milestone_id
              where m.type = 'Milestone'
                and m.project_id in (#{project_down_ids.join(',')})
              group by m.id) as budget_lines
       where m.type = 'Milestone'
         and m.project_id in (#{project_down_ids.join(',')})
         and m.id = budget_lines.id
         and ra.id = tl.role_id
       group by m.id, m.title, budget_lines.budget
       order by budget_lines.budget DESC, m.title
    ")   
  end
  
  # TODO: C - enhance to show roles with no current placements?
  def team
    @formative_roles = @project.formative_roles
    @incomplete_role_placements = @project.incomplete_role_placements
    @incomplete_resources = @project.incomplete_resources
    
    @page_title = @project.title
  end
  
  # TODO: B - Deliverables - milestones not yet implemented and who will sign.
  def deliverables
    raise NotImplementedError.new
  end
  
  # TODO C - links to completed project.library
  def library
    @page_title = @project.title
  end
  
  # TODO: C - Generic throughput of objects - opening, added, subtracted, closing.
  def throughput
    raise NotImplementedError.new
  end
  
  def dump
    project_ids = @project.self_and_descendant_project_ids(Status.incomplete) 
    @descendants = Item.find_all_by_project_id(project_ids,
      :include => [:status, :priority_code, :role, :person],
      :conditions => ['generic_stage in (?)', Status.incomplete],
      :order => 'items.type, codes.value, items.due_on' 
    )
  end
  
  def late
    project_ids = @project.self_and_descendant_project_ids(Status.incomplete) 
    @late_descendants = Item.find_all_by_project_id(project_ids,
      :include => [:status, :priority_code, :role, :person],
      :conditions => ['items.due_on < ? and generic_stage in (?)', Date.today, Status.incomplete],
      :order => 'items.type, codes.value, items.due_on' 
    )
  end
  
  # Displays the project hierarchy under this node in a tree arrangement.
  def hierarchy
    @page_title = @project.title
  end
  
  # Displays all children (incomplete including escalated)
  def all
    project_down_ids = @project.descendant_project_ids << @project.id
    project_up_ids = @project.ancestor_ids << @project.id
    @children = Item.find_all_by_project_id_and_project_id_escalation(
      project_down_ids, 
      project_up_ids, 
      :include => [:status, :priority_code],
      :conditions => ['generic_stage in (?)', Status.incomplete],
      :order => 'type, codes.value, due_on'
    )
  end
  
  # Responds with a graphic logo appropriate for this project.
  #
  # Finds the most recent file attachment named logo.(gif|ico|png|jpg) or looks in the next higher project.
  # Insert generic icon file if none attached to a project.
  # TODO: C - take advantage of nested set
	def logo
	  this_project = @project
	  expires_in 30.minutes
	  
	  until this_project.nil?
	    logger.debug "trying logo in project: #{this_project.title}"
		  attachment = this_project.attachments.find(:first, :conditions => "filename like 'logo.%'")
		  if attachment
		    logger.debug "using #{attachment.filename} in project: #{this_project.title}"
		    send_data attachment.attachment_content.data, :filename => attachment.filename, :type => attachment.mime_type, :disposition => 'inline'
		    return
		  end
		  this_project = this_project.parent
		end
		
	  # TODO: B - put realistic icon for CM
	  logger.debug "using default logo"
	  #send_file File.join(Pathname.new(RAILS_ROOT).realpath,'public/favicon.ico'), :disposition => 'inline'
	  redirect_to '/favicon.ico', :status => 302
	end
	
	# Show the current and future bookings for all people here or escalated here. 
	def bookings	  
	  project_down_ids = @project.descendant_project_ids << @project.id
    project_up_ids = @project.ancestor_ids << @project.id
    find_options = Hash.new
    find_options[:include] = [{:role_placements => {:role => :parent}}, :status]
    find_options[:conditions] = ['generic_stage in (?) and role_placements.end_on > now()', Status::alive]
    find_options[:order] = 'items.id, role_placements.start_on'
    @people = Person.find_all_by_project_id_and_project_id_escalation(
      project_down_ids, 
      project_up_ids, 
      find_options
    )
  end
	
	def roadmap
	  all_milestones = Array.new
	  @dot_spec = roadmap_dot_preamble
	  defined = Hash.new
	  
	  # subgraphs for children
	  child_projects = @project.children_by_class(Project)
	  child_projects.each do |child|
	    @dot_spec << roadmap_dot_subgraph(child, defined, all_milestones)
    end
	  
	  # natural 
	  child_milestones = @project.children_by_class(Milestone)
	  child_milestones.each do |milestone|
	    @dot_spec << roadmap_dot_node(milestone, defined, all_milestones)
    end
    
    # end of main graph
    @dot_spec << "  }\n\n"

	  # dependencies
	  milestone_ids = all_milestones.collect { |m| m.id }
	  all_milestones.each do |m|
      m.predecessor_dependencies.each do |p|
        if milestone_ids.include?(p.predecessor.id) || !p.predecessor.governing_project_ids.include?(@project.id) 
          @dot_spec << roadmap_dot_node(p.predecessor, defined) unless defined[p.predecessor.id]
          @dot_spec << roadmap_dot_dependency(m, p) 
        end
      end
    end
    
    @dot_spec << roadmap_dot_postamble
	  
	  dotinpath = "/tmp/roadmap.#{@project.id}.dot"
    cmapxoutpath = "/tmp/roadmap.#{@project.id}.cmapx"
    pngoutpath = "/tmp/roadmap.#{@project.id}.png"
    canonoutpath = "/tmp/roadmap.#{@project.id}.canon"
	  
	  File.open(dotinpath, 'w+') do |f|
	    f << @dot_spec
    end

    system "dot -Tpng -o#{pngoutpath} #{dotinpath}"
    system "dot -Tcmapx -o#{cmapxoutpath} -Tcanon -o#{canonoutpath} #{dotinpath}"
    #raise @dot_spec
    
    cmapxfile = File.open(cmapxoutpath)
    @cmapx_text = cmapxfile.read
  end
  
  def roadmap_img
    pngoutpath = "/tmp/roadmap.#{@project.id}.png"
    send_file pngoutpath, :disposition => 'inline'
  end
  
  def defects
    @defects = @project.descendants_by_class(TestObservation)
       
    @defect_counts = Hash.new
    @defects.each do |d|
      milestone = d.detail.phase_detected_milestone
      @defect_counts[milestone] ||= Hash.new
      current = @defect_counts[milestone][d.status_id] || 0
      @defect_counts[milestone][d.status_id] = current + 1
    end
  end
  
  def defect_listing
    defects = @project.descendants_by_class(TestObservation)

    buffer = String.new
    buffer << (Item.to_csv_header + ',' + TestObservationDetail.to_csv_header + "\n")
    defects.each do |d|
      item_line = d.to_csv
      detail_line = d.detail.to_csv
      buffer << (item_line + "," + detail_line + "\n")
    end
    send_data buffer, :type => 'text/csv', :filename => "defect_listing-#{Time.now.strftime('%Y%m%d%H%M')}.csv"
  end
  
  protected
  
  # Loads the required item (initially for security checking) using params[:id] and caches it for other methods.
  # This method is called by the authorisation Application before_filter.
  def load_item(id)
    @project = Project.find(id, :include => :detail)
  end  
  
  def roadmap_dot_preamble
    "digraph roadmap {\n  graph [rankdir = LR, fontsize=10, fontname=Arial];\n  node [shape=box, fontsize=10, fontname=Arial];\n\n  subgraph cluster#{@project.id} {\n"
  end
  
  def roadmap_dot_postamble
    "}\n"
  end
  
  # return a dot cluster subgraph for the given project 
  def roadmap_dot_subgraph(child_project, defined, all_milestones)
    result = "    subgraph cluster#{child_project.id} {\n    graph [label=\"#{child_project.title}\"];\n"
    milestones = child_project.escalated_by_class(Milestone, Status::alive)
    milestones.each do |m|
      result << roadmap_dot_node(m, defined, all_milestones)
    end
    result << "    }\n\n"
    result
  end
  
  # define one node
  def roadmap_dot_node(m, defined, all_milestones = nil)
    defined[m.id] = true
    all_milestones << m unless all_milestones.nil?
    "    #{m.id} [URL=\"/milestone/#{m.id}\", label=\"#{m.title}\" #{m.status.value == Status::COMPLETE ? 'style=filled' : ''}];\n"
  end
  
  def roadmap_dot_dependency(milestone, dependency)
    "  #{dependency.predecessor.id} -> #{milestone.id} [color=#{dependency.is_critical ? 'red' : 'black'}, weight=#{dependency.is_critical ? 2 : 1}];\n"
  end
  
end
