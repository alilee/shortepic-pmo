require File.dirname(__FILE__) + '/../test_helper'
require 'change_request_controller'

# Re-raise errors caught by the controller.
class ChangeRequestController; def rescue_action(e) raise e end; end

class ChangeRequestControllerTest < Test::Unit::TestCase
  fixtures :codes, 
    :statuses, 
    :items, 
    :change_request_details,
    :cr_date_lines, 
    :cr_expense_lines, 
    :cr_effort_lines, 
    :associations, 
    :role_placements, 
    :role_security_profiles, 
    :role_details
  
  def setup
    @controller = ChangeRequestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @session = @request.session
    @user = Person.find(:first)
    @crs = ChangeRequest.find(:all) || []
    @session[:person] = @user
    @session[:auth_cache] = Hash.new
    @session[:project_link_cache] = Hash.new
  end

  def test_show
    @crs.each { |cr|
      get :show, { :id => cr.id }
      assert_response :success
    }
  end
  
  def test_edit
    @crs.each { |cr|
      get :edit, { :id => cr.id }
      assert_response :success
    }
      
    #On successful save, the response is a redirect to 'changerequest/list'
    #On unsuccessful save, the response is template 'changerequest/edit'
    #  with a div of class "errorExplanation".
    
    cr = @crs.first
    
    #Saving the Item without any changes
    post :edit, { :id => cr.id, :item => cr.attributes}
    assert_response :success
    assert_no_tag :tag => "div", :attributes => {:class => "errorExplanation"}
    
    #Saving the Item with changes (but valid change)
    post :edit, { :id => cr.id, :item => cr.attributes.merge({'title' => "The testing title."})}
    assert_response :success
    assert_no_tag :tag => "div", :attributes => {:class => "errorExplanation"}
    
    #Saving the Item without any title (Invalid Change)
    #must show the edit page with the errors div
    post :edit, { :id => cr.id, :item => cr.attributes.merge({'title' => "", 'role_id' => nil})}
    assert_response :success
    assert_template 'item/edit'
    assert_tag :tag => "div", :attributes => {:class => "errorExplanation"}
  end
  
  def test_new
    get :edit, { :project_id => 1 }
    assert_response :success
    assert_template 'item/edit'
    
    parent = Project.find(:first)
    code = Code.find_by_type_name("ChangeRequest")
    status = Status.find_by_type_name("ChangeRequest")
    role = Role.find(:first)
    person = Person.find(:first)
    attributes = { 'title' => 'Change Request Test 123',
                   'code_id_priority' => code.id,
                   'status_id' => status.id,
                   'project_id' => parent.id,
                   'role_id' => role.id,
                   'person_id' => person.id,
                   'project_id_escalation' => parent.id,
                   'due_on' => 3.months.from_now}
    
    #Posting Correct Data - Should Create A New Item
    post :edit,  {:project_id => 1, :item => attributes }
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
  
  def test_editors_present_in_edit
    get :edit, { :id => ChangeRequest.find(:first).id }
    assert_tag :tag => 'tr', :attributes => {:id => 'schedule_editor'}
    assert_tag :tag => 'tr', :attributes => {:id => 'effort_editor'}
    assert_tag :tag => 'tr', :attributes => {:id => 'expenses_editor'}
  end
end
