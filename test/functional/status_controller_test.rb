require File.dirname(__FILE__) + '/../test_helper'
require 'status_controller'

# Re-raise errors caught by the controller.
class StatusController; def rescue_action(e) raise e end; end

class StatusControllerTest < Test::Unit::TestCase
  fixtures :statuses, :role_security_profiles, :role_details
  
  def setup
    @controller = StatusController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @session = @request.session
    @user = Person.find(:first)
    @session[:person] = @user
    @session[:auth_cache] = Hash.new
    @session[:project_link_cache] = Hash.new
  end

  def test_manage
    get :manage
    assert_response :success
  end
  
  def test_edit_value
    attributes = {:generic_stage => Status::NEW, :type_name => "Project", :value => "Test_New"}
    ic = Status.new(attributes)
    assert ic.save
    final_value = 'Test_new_amended'
    post :edit_value, {:id => ic.id, :value => final_value}
    assert_response :success
    ic.reload
    assert_equal final_value, ic.value
  end
  
  def test_add_through_manage_action
    attributes = {:generic_stage => Status::NEW, :type_name => "Project", :value => "Test_New"}
    post :manage, {:new_status => attributes}
    assert_response :success
    assert_equal 'Status created successfully', flash[:notice]
    post :manage, {:new_status => attributes.merge(:generic_stage => "")}
    assert_response :success
    assert_template 'status/manage'
    assert_tag :tag => "div", :attributes => {:class => "errorExplanation"}
  end
  
  def test_manage_transitions
    get :manage_transitions
    assert_response :success
  end
  
  def test_add_wildcard
    attributes = { 
      :commit => 'add', 
      :status_from => '0', 
      :status_to => '0', 
      :new_transition => { :type_name => 'ActionItem', :code_id_security_profile => '0' } 
    }
    post :manage_transitions, attributes
    assert_response :success
  end
  
  def test_add_specific
    attributes = { 
      :commit => 'add', 
      :status_from => Status::REVIEW, 
      :status_to => Status::COMPLETE, 
      :new_transition => { :type_name => 'Absence', :code_id_security_profile => '0' } 
    }
    post :manage_transitions, attributes
    assert_response :success
  end

end
