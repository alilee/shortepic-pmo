# TODO: C - self register new users? system setting for default role and project
class LoginController < ApplicationController
  
  layout 'login_layout'
  
  skip_before_filter :check_auth
  
  # TODO: C - change session[:person] to be session[:users_name] and session[:users_id]
  # FIXME: D - why does the email address not get updated on Firefox without the cookie? 
  def login
    old_flash_notice = flash[:notice]
    reset_session
    flash[:notice] = old_flash_notice
    session[:auth_cache] = Hash.new
    @page_title = "Consultant Manager"
    
    if request.post?
      cookies[:email] = { :value => params[:email], :expires => 1.year.from_now }
      person = Person.find(:first, :include => :detail, :conditions => ['email = ?', params[:email]])

      unless params[:reset_password].nil?
        logger.warn("Password reset for #{params[:email]}")
        if person.nil?
          logger.warn("Password reset attempt failed")
          flash[:error] = "Email not valid"
          flash[:error_email] = true
        else
          person.detail.reset_next_login = false if person.detail.reset_next_login
          person.reset_password()
          flash[:notice] = 'Password has been reset - check your email'
        end
        render
        return
      end

      if person.nil? || person.detail.res_password_hash != Person.hash_password(params[:password], person.detail.res_password_salt)
        logger.warn("Login attempt failed: #{params[:email]}")
        flash[:error] = "Login failed. Email address and/or password incorrect"
        flash[:error_email] = true
        flash[:error_password] = true
        render
        return
      end
      
      unless params[:new_password].nil? || params[:new_password].length == 0
        if params[:new_password] != params[:confirm_password]
          flash[:error] = "Unable to change password as the two passwords are not the same. Please try again."
          flash[:error_new_password] = true
          render
          return
        elsif params[:new_password] == params[:password]
          flash[:error] = "Unable to change password as the new is the same as the old. Please try again."
          flash[:error_new_password] = true
          render
          return
        elsif Person.weak_password(params[:new_password])
          flash[:error] = "Unable to change password as your new password is not secure enough."
          flash[:error_new_password] = true
          render
          return
        else
          person.detail.reset_next_login = false if person.detail.reset_next_login
          person.set_password(params[:new_password])
          flash[:notice] = "Password changed"
        end
      else
        if person.detail.reset_next_login
          flash[:error] = "You need to change your password before you can login"
          render
          return
        end 
      end
      
      logger.info("Logging in: #{person.id}")
      load_session_cache(person)
      expire_person_cache(person)
      redirect_to index_url
    end
    
    params[:email] = cookies[:email]
  end
  
  def logout
    reset_session
    session[:auth_cache] = Hash.new
    session[:project_link_cache] = Hash.new
    redirect_to login_url
  end
  
  def admit_one
    @person = Person.new(params[:person])
    @person.detail.attributes = params[:detail]
    @detail = @person.detail
    @project = Project.new(params[:project])
    
    if request.post? && LoginController.create_project_for(@person, @project)
      @person.reset_password
      cookies[:email] = @person.detail.email
      flash[:notice] = 'Account and project created. Check your email for login credentials.'      
      redirect_to :action => :login
      return
    end
    
    @page_title = 'Create new project administrator'
  end
  
  protected
  
  # Populate the session with all details on successful login.
  def load_session_cache(person)
    session[:person] = person
    
    reload_project_cache()
  end
  
  # Expire all cache fragments related to this person
  def expire_person_cache(person)
    r = "person/#{person.id}/.*"
    expire_fragment(Regexp.new(r))
  end
  
  def self.create_project_for(person, project)
    begin
      Item.transaction do 
        # Complete the new root project
        project.status = Status.find_by_type_name_and_enabled(Project.name, true, :order => 'generic_stage')
        project.person_id = 0
        project.due_on = Date.today
        project.project_id = 0
        project.role_id = 0
        project.priority_code = Code.find_by_type_name_and_name_and_enabled(Project.name, 'Priority', true, :order => 'value')
        project.project_id_escalation = 0
        project.person_id_updated_by = 0
        project.save_with_validation(false)

        # Complete the person
        person.status = Status.find_by_type_name_and_enabled(Person.name, true, :order => 'generic_stage')
        person.person_id = 0
        person.due_on = Date.today
        person.project_id = project.id
        person.role_id = 0 
        person.priority_code = Code.find_by_type_name_and_name_and_enabled(Person.name, 'Priority', true, :order => 'value')
        person.project_id_escalation = project.id
        person.person_id_updated_by = 0
        person.detail.timezone_code = Code.find_by_type_name_and_name_and_enabled(Person.name, 'Timezone', true)
        person.save_with_validation(false)
    
        # Complete the role
        role_attributes = {
          :title => "#{project.title} administrator",
          :status => Status.find_by_type_name_and_enabled(Role.name, true, :order => 'generic_stage'),
          :person_id => person.id,
          :due_on => Date.today,
          :project_id => project.id,
          :role_id => 0, 
          :priority_code => Code.find_by_type_name_and_name_and_enabled(Role.name, 'Priority', true, :order => 'value'),
          :project_id_escalation => project.id,
          :person_id_updated_by => 0
        }
        role = Role.new(role_attributes)
        role.detail.security_profile_code = Code.find_by_type_name_and_name_and_value(Role.name, 'Security profile', 
          SystemSetting.system_setting('Administration', 'Administrator security profile value', 'Administrator') )
        role.save_with_validation(false)
          
        # fix up self-referential links
        project.person = person
        project.role = role
        project.updated_by = person
        project.save!
      
        person.person = person
        person.role = role
        person.updated_by = person
        person.save!
    
        role.role = role
        role.updated_by = person
        role.save!
    
        # Add the person to the administrators role in the Administrators project.
        RolePlacement.create!(
          :person_id => person.id,
          :role_id => role.id,
          :start_on => Date.today,
          :end_on => 10.years.from_now.to_date,
          :committed_hours => 0,
          :normal_hourly_rate => 0
        )
      end
      return true
    rescue Exception => e
      return false
    end
  end
  
end
