module ItemHelper

  # Return the possible values for projects to escalate this item to.
  #
  # Item could be new or root.
  def select_for_project_escalation(item)
    result = item.ancestor_projects.collect {|pe| [ pe.title, pe.id ] }
    result.reverse << [ '<Not escalated>', 0 ]
  end
  
  # generate a select of all objects of a certain class, optionally under a certain project
  def select_for_project_descendants(klass, project = nil)
    if project.nil?
      klass.find(:all, :order => 'title').collect {|r| [ r.title, r.id ] }
    else
      project.descendants_by_class(klass).collect {|r| [r.title, r.id] }
    end
  end

  def select_for_budgeted_milestone(person)
    return [] if person.current_role_assignments == []
    CrEffortLine.find_all_by_role_id(
      person.current_role_assignments.collect {|pa| pa.role_id}, 
      :include => [:milestone, {:role => :status}], 
      :conditions => ['generic_stage in (?)', Status::incomplete]).collect { |el| [el.milestone.title, el.milestone.id] }
  end
  
  def select_for_signatories(item)
    select_for_authorised_people(item)
  end
  
  # Return the valid statuses for this item to transition to, given its type and the rights of the user
  def select_for_next_valid_status(item)
    profiles = session[:person].current_profile_ids_over(item.class == Project && !item.new_record? ? item.id : item.project_id)
    transitions = StatusTransition.find_all_valid(item.class.name, profiles, item.status_id)
    transitions_to = transitions.collect {|t| t.status_id_to }
    transitions_to << item.status_id unless transitions_to.include? item.status_id
    if transitions_to.include? 0
      result = Status.find_all_by_type_name_and_enabled(item.class.name, true, :order => 'sequence')
    else
      result = Status.find_all_by_type_name_and_enabled_and_id(item.class.name, true, transitions_to, :order => 'sequence')
    end    
    result.collect {|s| [s.value, s.id] }
  end

  # Return the people who are authorised to see this item, so they can be considered for the assignee
  def select_for_authorised_people(item)
    # Roles in this parent projects
    project_ids = [item.project_id, item.id] # in case object is itself a project
    project_ids.concat item.parent.ancestor_ids unless item.parent.nil?
    
    people = Person.find(:all, 
      :include => { :role_placements => :role },
      :conditions => ['roles_role_placements.project_id in (?) and now() between start_on and end_on', project_ids],
      :order => 'items.title'
    )
    people.collect {|p| [p.title, p.id] }.uniq
  end
  
  # All items (of a given class) which the user can currently see through placements in roles.
  # If add_root, can also be able to see the root of the project hierarchy.
  # TODO: C - improve by writing in a single SQL
  def select_for_visibility_to_user(klass = Item, add_root = false)
    project_ids = session[:person].current_project_tree_ids
    result = klass.find(:all,
      :conditions => ['project_id in (?) or id in (?)', project_ids, project_ids],
      :order => 'title').collect {|i| [ i.title, i.id ]}
    result << root_project if add_root
    result
  end

  # All items (of a given class) which the user can currently see through placements in roles.
  def select_detail_for_visibility_to_user(klass, allow_root = false)
    project_ids = session[:person].current_project_tree_ids
    result = klass.find(:all,
      :conditions => ['project_id in (?) or items.id in (?)', project_ids, project_ids],
      :include => :detail,
      :order => 'title').collect {|i| [ i.title, i.detail.id ]}
    result << [ '<No parent>', 0 ] if allow_root
    result
  end
  
  # All items of a given class which the user can see through current placements, and which has visibility of the given object.
  # For example select_for_visibility_and_authority(Role, @item) will return the Roles which the current user can see, which
  # can also see the given item. 
  #
  # Get all the parents of the item. Compare the parents of the item to the projects the user is in. Those that overlap are checked
  # presence of the klass.
  # 
  # If this object is a project, then things inside it can see it. Also, I can see the project I am on.
  # If the item is a root project, then 
  def select_for_visibility_and_authority(klass, item)
    # all the project ids the user can see
    user_project_ids = session[:person].current_project_tree_ids
    result_project_ids = user_project_ids & item.governing_project_ids
    if result_project_ids.empty?
      []
    else
      klass.find_all_by_project_id(result_project_ids, :order => 'title').collect {|i| [i.title, i.id]}
    end
  end
  
  # All items of a given class escalated to the parent of the given item
  def select_for_escalation(klass, item)
    item.parent.escalated_by_class(klass, Status.in_progress).collect {|i| [i.title, i.id]}
  end

  # All items of a given class which are descendants of the item's parent.
  def select_for_visibility_from_item(klass, item)
    item.parent.descendants_by_class(klass).collect {|i| [i.title, i.id] if Status.incomplete.include?(i.status.generic_stage) }
  end
  
  # All items of a given class which are peers/siblings of the given item. Specifically exludes escalated.
  def select_for_peer(klass, item)
    klass.find(:all,
      :include => :status,
      :conditions => ['project_id = ? and generic_stage in (?)', item.project_id, Status.in_progress],
      :order => 'title' 
    ).collect {|i| [i.title, i.id]}
  end
  
  # Produce a class attribute for the error class
  def error_class
    'class="field-error"'
  end
  
  def line_error_class_if(field_sym, other_classes = '')
    error_class = @line.errors[field_sym] ? 'field-error' : 'no-field-error'
    'class="'+error_class+' '+other_classes+'"' 
  end
  
  # return the late class or nil if the given date is before today
  def overdue_class(item_or_date)
    'class="overdue"' if (item_or_date.kind_of?(Date) && item_or_date < Date.today) || (item_or_date.kind_of?(Item) && item_or_date.overdue?)
  end
  
  def root_project
    ['<Root project>', 0]
  end
  
  def table_headings(headings)
    result = String.new
    headings.each do |heading|
      result << '<th>' << h(heading) << '</th>'
    end
    result
  end
  
  def table_data(html)
    "<td>#{html}</td>"
  end
  
end
