require File.dirname(__FILE__) + '/../test_helper'
require 'timesheet_controller'

# Re-raise errors caught by the controller.
class TimesheetController; def rescue_action(e) raise e end; end

class TimesheetControllerTest < Test::Unit::TestCase
  fixtures :codes, 
    :statuses, 
    :items,
    :timesheet_details, 
    :timesheet_lines, 
    :cr_date_lines, 
    :cr_expense_lines, 
    :cr_effort_lines, 
    :associations, 
    :role_placements, 
    :role_security_profiles, 
    :role_details
  
  def setup
    @controller = TimesheetController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @session = @request.session
    @user = Person.find(:first)
    @timesheets = Timesheet.find(:all, :limit => 10) || []
    @session[:person] = @user
    @session[:auth_cache] = Hash.new
    @session[:project_link_cache] = Hash.new
    @project = Project.find(:first)
  end

  def test_show
    @timesheets.each { |i|
      get :show, { :id => i.id }
      assert_response :success
    }
  end

  def test_edit
    @timesheets.each { |timesheet|
      get :edit, { :id => timesheet.id }
      assert_response :success
    }
    
    timesheet = @timesheets.first
      
    #On successful save, the response is a redirect to 'timesheet/list'
    #On unsuccessful save, the response is template 'timesheet/edit'
    #  with a div of class "errorExplanation".
    
    #Saving the Item without any changes
    post :edit, { :id => timesheet.id, :item => timesheet.attributes}
    assert_response :success
    assert_no_tag :tag => "div", :attributes => {:class => "errorExplanation"}
    
    #Saving the Item with changes (but valid change)
    post :edit, { :id => timesheet.id, :item => timesheet.attributes.merge({'title' => "The testing title."})}
    assert_response :success
    assert_no_tag :tag => "div", :attributes => {:class => "errorExplanation"}
    
    #Saving the Item without any title (Invalid Change)
    #must show the edit page with the errors div
    post :edit, { :id => timesheet.id, :item => timesheet.attributes.merge({'title' => "", 'role_id' => nil})}
    assert_response :success
    assert_template 'item/edit'
    assert_tag :tag => "div", :attributes => {:class => "errorExplanation"}
  end

  def test_new
    get :edit, { :project_id => @project.id }
    assert_response :success
    assert_template 'item/edit'
    
    parent = Project.find(:first)
    code = Code.find_by_type_name("Timesheet")
    status = Status.find_by_type_name("Timesheet")
    role = Role.find(:first)
    person = Person.find(:first)
    attributes = { 'title' => 'Timesheet Test 123',
                   'code_id_priority' => code.id,
                   'status_id' => status.id,
                   'project_id' => parent.id,
                   'role_id' => role.id,
                   'person_id' => person.id,
                   'project_id_escalation' => parent.id,
                   'due_on' => 3.months.from_now}
    detailattributes = { 'period_ending_on' => 2.weeks.ago,
                   'person_id_worker' => person.id
                 }
    
    #Posting Correct Data - Should Create A New Item
    post :edit,  { :project_id => @project.id, :item => attributes, :detail => detailattributes }
    assert_response :redirect
    
    #Posting Incorrect Data - Should Not Save Item
    post :edit,  {:project_id => @project.id, :item => {} }
    assert_response :success
    assert_template 'item/edit'
    assert_tag :tag => "div", :attributes => {:class => "errorExplanation"}
  end

  def test_list
    get :list, {}
    assert_response :success
  end

end
