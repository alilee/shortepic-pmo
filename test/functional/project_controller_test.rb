require File.dirname(__FILE__) + '/../test_helper'
require 'project_controller'

# Re-raise errors caught by the controller.
class ProjectController; def rescue_action(e) raise e end; end

class ProjectControllerTest < Test::Unit::TestCase
  fixtures :codes, :statuses, :items, :project_details, :role_security_profiles, :role_details, :status_report_details, :status_transitions
  
  def setup
    @controller = ProjectController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @session = @request.session
    @user = Person.find(:first)
    @projects = Project.find(:all)
    @session[:person] = @user
    @session[:auth_cache] = Hash.new
    @session[:project_link_cache] = Hash.new
  end

  def test_show
    @projects.each { |p|
      get :show, { :id => p.id }
      assert_response :success
    }
  end
  
  def test_edit
    @projects.each { |project|
      get :edit, { :id => project.id }
      assert_response :success
    }
     
    project = @projects.first
     
    #On successful save, the response is a redirect to 'project/list'
    #On unsuccessful save, the response is template 'project/edit'
    #  with a div of class "errorExplanation".
    
    #Saving the Item without any changes
    post :edit, { :id => project.id, :item => project.attributes}
    assert_response :success
    assert_no_tag :tag => "div", :attributes => {:class => "errorExplanation"}
    
    #Saving the Item with changes (but valid change)
    post :edit, { :id => project.id, :item => project.attributes.merge({'title' => "The testing title."})}
    assert_response :success
    assert_no_tag :tag => "div", :attributes => {:class => "errorExplanation"}
    
    #Saving the Item without any title (Invalid Change)
    #must show the edit page with the errors div
    post :edit, { :id => project.id, :item => project.attributes.merge({'title' => "", 'role_id' => nil})}
    assert_response :success
    assert_template 'item/edit'
    assert_tag :tag => "div", :attributes => {:class => "errorExplanation"}
  end
  
  def test_new
    get :edit, { :project_id => 1 }
    assert_response :success
    assert_template 'item/edit'
    
    parent = Project.find(:first)
    code = Code.find_by_type_name("Project")
    status = Status.find_by_type_name("Project")
    role = Role.find(:first)
    person = Person.find(:first)
    attributes = { 'title' => 'Project Test 123',
                   'code_id_priority' => code.id,
                   'status_id' => status.id,
                   'project_id' => parent.id,
                   'role_id' => role.id,
                   'person_id' => person.id,
                   'project_id_escalation' => parent.id,
                   'due_on' => 3.months.from_now}
    
    #Posting Correct Data - Should Create A New Item
    post :edit,  {:project_id => parent.id, :item => attributes }
    assert_response :redirect
    
    #Posting Incorrect Data - Should Not Save Item
    post :edit,  {:project_id => parent.id, :item => {} }
    assert_response :success
    assert_template 'item/edit'
    assert_tag :tag => "div", :attributes => {:class => "errorExplanation"}

  end
  
  def test_list
    get :list, {}
    assert_response :success
  end
  
  def test_issues
    @projects.each { |p|
      get :issues, { :id => p.id }
      assert_response :success
    }
  end

  def test_risks
    @projects.each { |p|
      get :risks, { :id => p.id }
      assert_response :success
    }
  end
  
  def test_operations
    # TODO: - B need to test that escalated sub-projects are displayed on project.operations
    @projects.each { |p|
      get :operations, { :id => p.id }
      assert_response :success
    }
  end

  def test_library
    @projects.each { |p|
      get :library, { :id => p.id }
      assert_response :success
    }
  end  

  def test_team
    @projects.each { |p|
      get :team, { :id => p.id }
      assert_response :success
    }
  end
  
  def test_hierarchy
    @projects.each do |p|
      get :hierarchy, { :id => p.id }
      assert_response :success
    end
  end
  
  def test_plan
    @projects.each do |p|
      get :plan, { :id => p.id }
      assert_response :success
    end
  end

  def test_late
    @projects.each do |p|
      get :late, { :id => p.id }
      assert_response :success
    end
  end
  
  def test_edit_root_project
    project = Project.find_by_project_id(nil)
    assert_not_nil project
     
    #Saving the Item with changes (but valid change)
    new_title = "The testing title."
    assert_not_equal new_title, project.title
    post :edit, { :id => project.id, :item => project.attributes.merge({'title' => new_title})}
    assert_response :success
    assert_select 'td', 'Item saved'
    assert_select 'input[value=?]', new_title
  end
  
  def test_new_root_project_status
    p = Project.find(:first)
    get :edit, { :project_id => p.id }
    assert_response :success
    assert_template 'item/edit'
    assert_select 'select option', Status::NEW
  end
  
  def test_new_child_project_into_nestedset
    parent = Project.find(:first)
    code = Code.find_by_type_name_and_enabled("Project", true)
    status = Status.find_by_type_name_and_enabled("Project", true)
    role = Role.find(:first)
    person = Person.find(:first)
    attributes = { 'title' => 'Test child project',
                   'code_id_priority' => code.id,
                   'status_id' => status.id,
                   'project_id' => parent.id,
                   'role_id' => role.id,
                   'person_id' => person.id,
                   'project_id_escalation' => parent.id,
                   'due_on' => 3.months.from_now}
    
    #Posting Correct Data - Should Create A New Item
    post :edit,  {:project_id => parent.id, :item => attributes }
    assert_response :redirect
    
    parent.reload
    child = Project.find_by_title('Test child project')
    assert parent.lft < child.lft && parent.rgt > child.rgt
  end
  
  def test_new_root_project
    parent = Project.find(:first)
    code = Code.find_by_type_name_and_enabled("Project", true)
    status = Status.find_by_type_name_and_enabled("Project", true)
    role = Role.find(:first)
    person = Person.find(:first)
    attributes = { 'title' => 'Test root project',
                   'code_id_priority' => code.id,
                   'status_id' => status.id,
                   'project_id' => '0',
                   'role_id' => role.id,
                   'person_id' => person.id,
                   'project_id_escalation' => '0',
                   'due_on' => 3.months.from_now}
    
    #Posting Correct Data - Should Create A New Item and an associated Role
    post :edit,  {:project_id => parent.id, :item => attributes }
    assert_response :redirect
    follow_redirect
    assert_select 'td', 'Item saved'
    assert_select 'select#item_person_id option', person.title
    assert_select 'select#item_role_id option[selected=selected]', 'Test root project Administrator' 
    
    new_root = Project.find_by_title('Test root project')
    new_role = Role.find_by_project_id(new_root.id)
    assert_not_nil new_role
    assert_equal person.id, new_role.person_id
  end
      
end
