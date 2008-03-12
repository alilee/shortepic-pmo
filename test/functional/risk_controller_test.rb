require File.dirname(__FILE__) + '/../test_helper'
require 'risk_controller'

# Re-raise errors caught by the controller.
class RiskController; def rescue_action(e) raise e end; end

class RiskControllerTest < Test::Unit::TestCase
  fixtures :codes, :statuses, :items, :risk_details, :role_security_profiles, :role_details
  
  def setup
    @controller = RiskController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @session = @request.session
    @user = Person.find(:first)
    @risks = Risk.find(:all)
    @session[:person] = @user
    @session[:auth_cache] = Hash.new
    @session[:project_link_cache] = Hash.new
  end

  def test_show
    @risks.each { |i|
      get :show, { :id => i.id }
      assert_response :success
      assert_template 'item/show'
    }
  end

  def test_edit
    #assumes that the issue record exists in fixture
    @risks.each { |issue|
      get :edit, { :id => issue.id }
      assert_response :success
    }
    
    risk = @risks.first
      
    #Saving the Item without any changes
    post :edit, { :id => risk.id, :item => risk.attributes}
    assert_response :success
    assert_no_tag :tag => 'div', :attributes => {:class => 'errorExplanation'}
    
    #Saving the Item with changes (but valid change)
    post :edit, { :id => risk.id, :item => risk.attributes.merge({'title' => "The testing title."})}
    assert_response :success
    assert_no_tag :tag => "div", :attributes => {:class => 'errorExplanation'}
    
    #Saving the Item without any title (Invalid Change)
    #must show the edit page with the errors div
    post :edit, { :id => risk.id, :item => risk.attributes.merge({'title' => ""})}
    assert_response :success
    assert_template 'item/edit'
    assert_tag :tag => "div", :attributes => {:class => 'errorExplanation'}
  end

  def test_new
    get :edit, { :project_id => @user.project_id }
    assert_response :success
    assert_template 'item/edit'
    
    parent = Project.find(:first)
    code = Code.find_by_type_name_and_name('Risk', 'Priority')
    status = Status.find_by_type_name('Risk')
    role = Role.find(:first)
    person = Person.find(:first)
    attributes = { 'title' => 'Risk Test 123',
                   'code_id_priority' => code.id,
                   'status_id' => status.id,
                   'project_id' => parent.id,
                   'role_id' => role.id,
                   'person_id' => person.id,
                   'project_id_escalation' => parent.id,
                   'due_on' => 3.months.from_now}
    
    #Posting Correct Data - Should Create A New Item
    post :edit,  {:project_id => @user.project_id, :item => attributes }
    assert_response :redirect
    
    #Posting Incorrect Data - Should Not Save Item
    post :edit,  {:project_id => @user.project_id, :item => {} }
    assert_response :success
    assert_template 'item/edit'
    assert_tag :tag => 'div', :attributes => {:class => 'errorExplanation'}
  end

  def test_list
    get :list, {}
    assert_response :success
  end
  
end
