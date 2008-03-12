require File.dirname(__FILE__) + '/../test_helper'
require 'meeting_controller'

# Re-raise errors caught by the controller.
class MeetingController; def rescue_action(e) raise e end; end

class MeetingControllerTest < Test::Unit::TestCase
  fixtures :codes, :statuses, :items, :meeting_details, :meeting_attendees, :status_transitions
  
  def setup
    @controller = MeetingController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @session = @request.session
    @user = Person.find(:first)
    @meetings = Meeting.find(:all)
    @session[:person] = @user
    @session[:auth_cache] = Hash.new
    @session[:project_link_cache] = Hash.new
  end

  def test_show
    @meetings.each { |i|
      get :show, { :id => i.id }
      assert_response :success
      assert_template 'item/show'
    }
  end

  def test_edit
    #assumes that the issue record exists in fixture
    @meetings.each { |i|
      get :edit, { :id => i.id }
      assert_response :success
    }
    
    meeting = @meetings.first
      
    #Saving the Item without any changes
    post :edit, { :id => meeting.id, :item => meeting.attributes}
    assert_response :success
    assert_no_tag :tag => 'div', :attributes => {:class => 'errorExplanation'}
    
    #Saving the Item with changes (but valid change)
    post :edit, { :id => meeting.id, :item => meeting.attributes.merge({'title' => "The testing title."})}
    assert_response :success
    assert_no_tag :tag => "div", :attributes => {:class => 'errorExplanation'}
    
    #Saving the Item without any title (Invalid Change)
    #must show the edit page with the errors div
    post :edit, { :id => meeting.id, :item => meeting.attributes.merge({'title' => ""})}
    assert_response :success
    assert_template 'item/edit'
    assert_tag :tag => "div", :attributes => {:class => 'errorExplanation'}
  end

  def test_new
    get :edit, { :project_id => @user.project_id }
    assert_response :success
    assert_template 'item/edit'
    
    parent = Project.find(:first)
    code = Code.find_by_type_name_and_name('Meeting', 'Priority')
    status = Status.find_by_type_name_and_enabled('Meeting', true)
    role = Role.find(:first)
    person = Person.find(:first)
    attributes = { 'title' => 'Test 123',
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
