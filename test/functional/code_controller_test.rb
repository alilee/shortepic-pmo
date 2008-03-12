require File.dirname(__FILE__) + '/../test_helper'
require 'code_controller'

# Re-raise errors caught by the controller.
class CodeController; def rescue_action(e) raise e end; end

class CodeControllerTest < Test::Unit::TestCase
  fixtures :codes, :role_security_profiles, :role_details
  
  def setup
    @controller = CodeController.new
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
  
  def test_edit
    attributes = {:name => 'Priority', :type_name => 'Project', :value => 'Test_Value'}
    final_value = 'Test_Value_Final'
    ic = Code.new(attributes)
    assert ic.save
    post :edit, {:id => ic.id, :value => final_value}
    assert_response :success
    ic.reload
    assert_equal final_value, ic.value
  end
  
  def test_add_through_manage_action
    attributes = {:name => 'Priority', :type_name => 'Project', :value => 'Test_Value'}
    post :manage, {:new_code => attributes}
    assert_response :success
    assert_equal 'Code created successfully', flash[:notice]
    post :manage, {:new_code => attributes.merge(:name => '')}
    assert_response :success
    assert_template 'code/manage'
    assert_tag :tag => 'div', :attributes => {:class => 'errorExplanation'}
  end
  
end
