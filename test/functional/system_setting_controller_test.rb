require File.dirname(__FILE__) + '/../test_helper'
require 'system_setting_controller'

# Re-raise errors caught by the controller.
class SystemSettingController; def rescue_action(e) raise e end; end

class SystemSettingControllerTest < Test::Unit::TestCase
  fixtures :system_settings, :role_security_profiles, :role_details
  
  def setup
    @controller = SystemSettingController.new
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
    attributes = {:name => "Test_Name1", :category => "Links", :value => "Test_Value"}
    final_value = "Test_Value_Final"
    ss = SystemSetting.new(attributes)
    assert ss.save
    post :edit_value, {:id => ss.id, :value => final_value}
    assert_response :success
    ss.reload
    assert_equal final_value, ss.value
  end
  
  def test_add_through_manage_action
    attributes = {:name => "Test_Name2", :category => "Test_Category", :value => "Test_Value"}
    post :manage, {:new_setting => attributes}
    assert_response :success
    assert_equal 'Setting created successfully', flash[:notice]
    post :manage, {:new_setting => attributes.merge(:name => "")}
    assert_response :success
    assert_template 'system_setting/manage'
    assert_tag :tag => "div", :attributes => {:class => "errorExplanation"}
  end
  
end
