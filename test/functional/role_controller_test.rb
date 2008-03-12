require File.dirname(__FILE__) + '/../test_helper'
require 'role_controller'

class FakeFile
  attr_accessor :original_filename, :content_type, :read, :size
  def initialize(original_filename, content_type, read, size)
    @original_filename = original_filename
    @content_type = content_type
    @read = read
    @size = size
  end
end

def File
    def size
        self.stat.size
    end
end

# Re-raise errors caught by the controller.
class RoleController; def rescue_action(e) raise e end; end

class RoleControllerTest < Test::Unit::TestCase
  fixtures :codes, :statuses, :items, :role_details, :role_security_profiles, :status_transitions
  
  def setup
    @controller = RoleController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @session = @request.session
    @user = Person.find(:first)
    @roles = Role.find(:all) || []
    @session[:person] = @user
    @session[:auth_cache] = Hash.new
    @session[:project_link_cache] = Hash.new
    @request.env["HTTP_REFERER"] = 'show/'+@user.id.to_s
  end

  def test_show
    @roles.each { |r|
      get :show, { :id => r.id }
      assert_response :success
    }
  end

  def test_edit
    @roles.each { |role|
      get :edit, { :id => role.id }
      assert_response :success
    }
    
    role = @roles.first
      
    #On successful save, the response is a redirect to 'role/list'
    #On unsuccessful save, the response is template 'role/edit'
    #  with a div of class "errorExplanation".
    
    #Saving the Item without any changes
    post :edit, { :id => role.id, :item => role.attributes}
    assert_response :success
    assert_no_tag :tag => "div", :attributes => {:class => "errorExplanation"}
    
    #Saving the Item with changes (but valid change)
    post :edit, { :id => role.id, :item => role.attributes.merge({'title' => "The testing title."})}
    assert_response :success
    assert_no_tag :tag => "div", :attributes => {:class => "errorExplanation"}
    
    #Saving the Item without any title (Invalid Change)
    #must show the edit page with the errors div
    post :edit, { :id => role.id, :item => role.attributes.merge({'title' => "", 'role_id' => nil})}
    assert_response :success
    assert_template 'item/edit'
    assert_tag :tag => "div", :attributes => {:class => "errorExplanation"}
  end

  def test_new
    get :edit, { :project_id => @user.project_id }
    assert_response :success
    assert_template 'item/edit'
    
    parent = Project.find(:first)
    code = Code.find_by_type_name("Role")
    status = Status.find_by_type_name("Role")
    role = Role.find(:first)
    person = Person.find(:first)
    attributes = { 'title' => 'Role Test 123',
                   'code_id_priority' => code.id,
                   'status_id' => status.id,
                   'project_id' => parent.id,
                   'role_id' => role.id,
                   'person_id' => person.id,
                   'project_id_escalation' => parent.id,
                   'due_on' => 3.months.from_now }
    detail_attrs = { 'code_id_security_profile' => Code.find_by_type_name_and_name('Role', 'Security profile') }
    
    #Posting Correct Data - Should Create A New Item
    post :edit,  {:project_id => 1, :item => attributes, :detail => detail_attrs  }
    assert_response :redirect
    
    #Posting Incorrect Data - Should Not Save Item
    post :edit,  {:project_id => 1, :item => {} }
    assert_response :success
    assert_template 'item/edit'
    assert_tag :tag => "div", :attributes => {:class => "errorExplanation"}
  end

  def test_list
    get :list, {}
    assert_response :success
  end
  
  def test_add_attachment
    item = Role.find(:first)
    data = "test file contents"
    
    # Uploading without version info
    post(:add_attachment, {:file_uploaded => FakeFile.new('/tmp/test.txt', 'text/plain', data, data.size), :id => item.id})
    assert_equal 'Version is too short (minimum is 1 characters)', flash[:attachment_error]
    assert_response :redirect
    
    # Uploading with version info
    post(:add_attachment, {:file_uploaded => FakeFile.new('/tmp/test.txt', 'text/plain', data, data.size), :attachment => {:version => '1.0'}, :id => item.id})
    assert_equal 'File uploaded successfully', flash[:attachment_notice]
    assert_response :redirect
    
    # Uploading same file with same version info
    post(:add_attachment, {:file_uploaded => FakeFile.new('/tmp/test.txt', 'text/plain', data, data.size), :attachment => {:version => '1.0'}, :id => item.id})
    assert_equal 'Version already available. Please upload a new version of the file.', flash[:attachment_error]
    assert_response :redirect
  end
  
  def test_download_attachment
    item = Role.find(:first)
    data = "test file contents"
    
    # Uploading a file with version info
    post(:add_attachment, {:file_uploaded => FakeFile.new('/tmp/test.txt', 'text/plain', data, data.size), :attachment => {:version => '1.0'}, :id => item.id})
    assert_equal 'File uploaded successfully', flash[:attachment_notice]
    assert_response :redirect

    # Downloading the file
    attachment_id = item.attachments.first.id
    post(:download_attachment, {:attachment_id => attachment_id, :id => item.id})
    assert_response :success
    
    # Downloading the incorrect file
    attachment_id += 20
    post(:download_attachment, {:attachment_id => attachment_id, :id => item.id})
    assert_response :redirect
  end
    
  # 1. matching on set|*, *|set, set|set, *|*
  def test_security_matching
    # 
    
  end

  # 2. not matching on set|*, *|set, set|set
  def test_security_not_matching
    
  end
  
  # 3. item in role project, item below role project, item above role project, item beside role project
  def test_security_item_projects
    
  end
  
  # 4. role not current 
  def test_security_current_roles
    
  end
    
  def test_responsibilities
    @roles.each do |r|
      get :responsibilities, { :id => r.id }
      assert_response :success
    end
  end
  
  def test_child_table_editor_present
    role = Role.find(:first)
    get :edit, { :id => role.id }
    assert_tag :tag => 'tr', :attributes => {:id => 'role_placements_editor'}
  end
  
  #
  # Status transitions
  #
  # 1. save with no change
  def test_transitions_status_unchanged
    r = Role.find(:first)
    assert_not_nil r
    get :edit, { :id => r.id }
    assert_response :success
    
    #Saving the Item with changes (but valid change)
    post :edit, { :id => r.id, :item => r.attributes.merge({'title' => "A title change."})}
    assert_response :success
    assert_select 'td', 'Item saved'
    
    get :show, { :id => r.id }
    assert_response :success
    assert_select 'td', 'A title change.'
  end 
      
  # 2. save new and then with valid change from specific to specific
  def test_transitions_specific
    p = Person.find_by_title('Uncle person')
    assert p.current_roles.size == 1
    r = p.current_roles.first
    assert r.title == 'Pending role'
    assert r.detail.security_profile_code.value == 'User'
    s_nil = Status.find_by_type_name_and_generic_stage(Role.name, Status::NIL)
    s_new = Status.find_by_type_name_and_generic_stage_and_enabled(Role.name, Status::NEW, true)
    s_in_progress = Status.find_by_type_name_and_generic_stage_and_enabled(Role.name, Status::IN_PROGRESS, true)
    assert_not_nil StatusTransition.find_by_type_name_and_status_id_from_and_status_id_to_and_code_id_security_profile(Role.name, [0,s_nil.id], [0,s_new.id], [0, r.detail.security_profile_code.id])
    
    @session[:person] = p
      
    get :edit, { :project_id => r.project_id }
    assert_response :success
    assert_template 'item/edit'  
    assert_select 'select#item_status_id option', Status::NEW 
    
    priority_code = Code.find_by_type_name_and_name(Role.name, 'Priority')
    assert_not_nil priority_code
    attributes = { 'title' => 'New Role',
                   'code_id_priority' => priority_code.id,
                   'status_id' => s_new.id,
                   'project_id' => r.project_id,
                   'role_id' => r.id,
                   'person_id' => p.id,
                   'project_id_escalation' => '0',
                   'due_on' => 3.months.from_now }
    detail_attrs = { 'code_id_security_profile' => r.detail.security_profile_code.id }
    r_new = Role.new(attributes)
    r_new.detail.attributes = detail_attrs

    post :edit,  {:project_id => r.project_id, :item => attributes, :detail => detail_attrs  }
    assert_response :redirect
    follow_redirect
    assert_select 'td', 'Item saved'
    assert_select 'select#item_status_id option', Status::IN_PROGRESS 
    @response.headers['Location'] =~ /role\/(\d+)\/edit/
    new_id = $1
    
    attributes['status_id'] = s_in_progress.id
    post :edit,  {:id => new_id, :item => attributes, :detail => detail_attrs  }
    assert_response :success
    assert_select 'td', 'Item saved'    
  end

  # 3. save with valid change from specific to any
  def test_transitions_specific_to_any
    p = Person.find_by_title('Uncle person')
    assert p.current_roles.size == 1
    r = Role.find(:first,
      :include => :status,
      :conditions => ['generic_stage = ?', Status::WITHDRAWN])
    assert r.detail.security_profile_code.value == 'User'
    assert r.title = 'Withdrawn role'

    s_withdrawn = Status.find_by_type_name_and_generic_stage_and_enabled(Role.name, Status::WITHDRAWN, true)
    s_complete = Status.find_by_type_name_and_generic_stage_and_enabled(Role.name, Status::COMPLETE, true)
    
    assert_not_nil StatusTransition.find_by_type_name_and_status_id_from_and_status_id_to_and_code_id_security_profile(Role.name, s_withdrawn.id, 0, [0, r.detail.security_profile_code.id])
    @session[:person] = p
      
    get :edit, { :id => r.id }
    assert_response :success
    assert_template 'item/edit'  
    assert_select 'select#item_status_id option', 6 
    
    attributes = r.attributes
    detail_attrs = r.detail.attributes
    attributes['status_id'] = s_complete.id

    post :edit,  {:id => r.id, :item => attributes, :detail => detail_attrs  }
    assert_response :success
    assert_select 'select#item_status_id option'
    assert_select 'td', 'Item saved'    
  end
  
  # 4. save with valid change from any to specific
  def test_transitions_any_to_specific
    p = Person.find_by_title('Uncle person')
    assert p.current_roles.size == 1
    r = Role.find(:first,
      :include => :status,
      :conditions => ['generic_stage = ?', Status::PENDING])
    assert r.detail.security_profile_code.value == 'User'

    s_pending = Status.find_by_type_name_and_generic_stage_and_enabled(Role.name, Status::PENDING, true)
    s_new = Status.find_by_type_name_and_generic_stage_and_enabled(Role.name, Status::NEW, true)
    
    assert_not_nil StatusTransition.find_by_type_name_and_status_id_from_and_status_id_to_and_code_id_security_profile(Role.name, 0, s_new.id, [0, r.detail.security_profile_code.id])
    @session[:person] = p
      
    get :edit, { :id => r.id }
    assert_response :success
    assert_template 'item/edit'  
    assert_select 'select#item_status_id option', Status::NEW 
    
    attributes = r.attributes
    detail_attrs = r.detail.attributes
    attributes['status_id'] = s_new.id

    post :edit,  {:id => r.id, :item => attributes, :detail => detail_attrs  }
    assert_response :success
    assert_select 'td', 'Item saved'
    assert_select 'select#item_status_id option[selected=selected]', Status::NEW   
  end
  
  # 5. save with invalid change even though another profile is allowed
  def test_transitions_invalid
    p = Person.find_by_title('Uncle person')
    assert p.current_roles.size == 1
    r = Role.find(:first,
      :include => :status,
      :conditions => ['generic_stage = ?', Status::PENDING])
    assert r.detail.security_profile_code.value == 'User'

    s_pending = Status.find_by_type_name_and_generic_stage_and_enabled(Role.name, Status::PENDING, true)
    s_complete = Status.find_by_type_name_and_generic_stage_and_enabled(Role.name, Status::COMPLETE, true)
    
    assert_nil StatusTransition.find_by_type_name_and_status_id_from_and_status_id_to_and_code_id_security_profile(Role.name, [0, s_pending.id], [0, s_complete.id], [0, r.detail.security_profile_code.id])
    assert_not_nil StatusTransition.find_by_type_name_and_status_id_from_and_status_id_to(Role.name, [0, s_pending.id], [0, s_complete.id])

    @session[:person] = p
      
    get :edit, { :id => r.id }
    assert_response :success
    assert_template 'item/edit'  
    assert_select 'select#item_status_id option', 2 
    assert_select 'select#item_status_id option', Status::NEW
    assert_select 'select#item_status_id option', Status::PENDING
    
    attributes = r.attributes
    detail_attrs = r.detail.attributes
    attributes['status_id'] = s_complete.id

    post :edit,  {:id => r.id, :item => attributes, :detail => detail_attrs  }
    assert_response :success
    assert_select 'div#errorExplanation'    
  end   
    
end
