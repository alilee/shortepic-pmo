require File.dirname(__FILE__) + '/../test_helper'
require 'security_profile_controller'

# Re-raise errors caught by the controller.
class SecurityProfileController; def rescue_action(e) raise e end; end

class SecurityProfileControllerTest < Test::Unit::TestCase
  fixtures :codes, :statuses, :items, :role_security_profiles

  def setup
    @controller = SecurityProfileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @session = @request.session
    @user = Person.find(:first)
    @session[:person] = @user
    @session[:auth_cache] = Hash.new
    @session[:project_link_cache] = Hash.new
  end

  # Replace this with your real tests.
  def test_truth
    get :manage
    assert_response :success
  end
end
