require File.dirname(__FILE__) + '/../test_helper'
require 'issue_controller'

# Re-raise errors caught by the controller.
class IssueController; def rescue_action(e) raise e end; end

class IssueControllerTest < Test::Unit::TestCase
  fixtures :codes, :statuses, :items, :issue_details, :role_security_profiles, :role_details
  
  def setup
    @controller = IssueController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @session = @request.session
    @user = Person.find(:first)
    @issues = Issue.find(:all)
    @session[:person] = @user
    @session[:auth_cache] = Hash.new
    @session[:project_link_cache] = Hash.new
  end

  def test_show
    @issues.each { |i|
      get :show, { :id => i.id }
      assert_response :success
      assert_template 'item/show'
    }
  end

  def test_edit
    #assumes that the issue record exists in fixture
    @issues.each { |issue|
      get :edit, { :id => issue.id }
      assert_response :success
    }
    
    issue = @issues.first
      
    #On successful save, the response is a redirect to 'issue/show'
    #On unsuccessful save, the response is template 'issue/edit'
    #  with div of class "errorExplanation".
    
    #Saving the Item without any changes
    post :edit, { :id => issue.id, :item => issue.attributes}
    assert_response :success
    assert_no_tag :tag => 'div', :attributes => {:class => 'errorExplanation'}
    
    #Saving the Item with changes (but valid change)
    post :edit, { :id => issue.id, :item => issue.attributes.merge({'title' => "The testing title."})}
    assert_response :success
    assert_no_tag :tag => "div", :attributes => {:class => 'errorExplanation'}
    
    #Saving the Item without any title (Invalid Change)
    #must show the edit page with the errors div
    post :edit, { :id => issue.id, :item => issue.attributes.merge({'title' => ""})}
    assert_response :success
    assert_template 'item/edit'
    assert_tag :tag => "div", :attributes => {:class => 'errorExplanation'}
  end

  def test_new
    get :edit, { :project_id => @user.project_id }
    assert_response :success
    assert_template 'item/edit'
    
    parent = Project.find(:first)
    code = Code.find_by_type_name('Issue')
    status = Status.find_by_type_name('Issue')
    role = Role.find(:first)
    person = Person.find(:first)
    attributes = { 'title' => 'Issue Test 123',
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
  
  def test_associate
    get :show, { :id => @issues.first.id }
    assert_response :success
    get :associate, { :id => @issues.first.id, :searchitem => { :title => "" } }
    assert_response 302
    get :associate, { :id => @issues.first.id, :searchitem => { :title => @user.title } }
    assert_response 302
  end

end
