desc 'Create full set of Statuses and priority Codes for testing'
task :create_test_statuses_and_codes => :environment do
  Status::DOMAIN_TYPES.each_value do |dt|
    dt.each do |t|
      Status::VALID_GENERIC.each do |gs|
        s = Status.find_or_initialize_by_type_name_and_generic_stage(t.name, gs)
        s.update_attributes!(:value => gs, :enabled => (gs != Status::NIL)) if s.new_record?
      end
      c = Code.find_or_initialize_by_type_name_and_name(t.name, 'Priority')
      c.update_attributes!(:value => 'Standard') if c.new_record?
      
      # Transitions
      root_profile = Code.find_by_type_name_and_name_and_value(Role.name, 'Security profile', 'Root')
      admin_profile = Code.find_by_type_name_and_name_and_value(Role.name, 'Security profile', 'Administrator')
      unless admin_profile.nil? || root_profile.nil?
        StatusTransition.find_or_create_by_type_name_and_status_id_from_and_status_id_to_and_code_id_security_profile(
          t.name, 
          0, 0, 
          admin_profile.id)
        StatusTransition.find_or_create_by_type_name_and_status_id_from_and_status_id_to_and_code_id_security_profile(
          t.name, 
          0, 0, 
          root_profile.id)
      end
    end
  end
end

# FIXME: C - the lack of initial values messes up the logic of the first versions saved. 
desc 'Create initial data set for clean install.'
task :initial_data => :environment do 
  # Codes
  project_priority = Code.find_or_create_by_type_name_and_name_and_value('Project', 'Priority', 'Standard')
  person_priority = Code.find_or_create_by_type_name_and_name_and_value('Person', 'Priority', 'Standard')
  role_priority = Code.find_or_create_by_type_name_and_name_and_value('Role', 'Priority', 'Standard')
  root_security_code = Code.find_or_create_by_type_name_and_name_and_value_and_enabled('Role', 'Security profile', 'Root', false)
  tz_code = Code.find_or_create_by_type_name_and_name_and_value('Person', 'Timezone', 'UTC')

  # Security profile
  root_security_profile = RoleSecurityProfile.find_or_create_by_code_id_security_profile(root_security_code.id)

  # Statuses
  Status::VALID_TYPES.each do |t|
    {Status::COMPLETE => 'Complete', Status::IN_PROGRESS => 'In progress', Status::NIL => 'Unborn'}.each do |k,v|
      Status.create!(:type_name => t.name, :generic_stage => k, :value => v, :enabled => (k != Status::NIL))
    end
  end
  
  project_status = Status.find_or_create_by_type_name_and_generic_stage('Project', Status::IN_PROGRESS)
  person_status = Status.find_or_create_by_type_name_and_generic_stage('Person', Status::IN_PROGRESS)
  role_status = Status.find_or_create_by_type_name_and_generic_stage('Role', Status::IN_PROGRESS)
  
  # Status transitions to allow root user to do anything.
  Status::VALID_TYPES.each do |t|
    StatusTransition.find_or_create_by_type_name_and_status_id_from_and_status_id_to_and_code_id_security_profile(
      t.name, 
      0, 0, 
      root_security_code.id
    )
  end
  
  Item.transaction do
    # Root project
    root_project = Project.new(
      :title => 'Administrator\'s project',
      :status_id => project_status.id,
      :code_id_priority => project_priority.id,
      :role_id => 0,
      :person_id => 0,
      :person_id_updated_by => 0
    )
    root_project.save_with_validation(false)
  
    # Root person
    root_person = Person.new(
      :title => 'Installer',
      :status_id => person_status.id,
      :code_id_priority => person_priority.id,
      :role_id => 0,
      :person_id => 0,
      :person_id_updated_by => 0
    )
    root_person.detail.attributes = {
      :email => 'new_root_user@shortepic.com',
      :code_id_timezone => tz_code.id
    }
    root_person.save_with_validation(false)
  
    # Root role
    root_role = Role.new(
      :title => 'Site Administrator',
      :status_id => role_status.id,
      :code_id_priority => role_priority.id,
      :role_id => 0,
      :person_id => 0,
      :person_id_updated_by => 0
    )
    root_role.detail.attributes = {
      :code_id_security_profile => root_security_code.id
    }
    root_role.save_with_validation(false)
  
    # Patch up references
    root_person.project_id = root_project.id
    root_person.project_id_escalation = root_project.id
    root_role.project_id = root_project.id
    root_role.project_id_escalation = root_project.id
  
    root_project.role_id = root_role.id
    root_person.role_id = root_role.id
    root_role.role_id = root_role.id
  
    root_project.person_id = root_person.id
    root_person.person_id = root_person.id
    root_role.person_id = root_person.id

    root_project.person_id_updated_by = root_person.id
    root_person.person_id_updated_by = root_person.id
    root_role.person_id_updated_by = root_person.id
  
    root_project.save!
    root_role.save!
    root_person.save!
    root_person.set_password('abc') # also performs save!
  
    # Now place the root user into the new role
    RolePlacement.create(
      :person_id => root_person.id,
      :role_id => root_role.id,
      :start_on => Date.today,
      :end_on => 10.years.from_now.to_date,
      :committed_hours => 0,
      :normal_hourly_rate => 0
    )
    
  end
end