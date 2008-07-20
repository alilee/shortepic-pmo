require File.dirname(__FILE__) + '/../test_helper'
require 'release_controller'

# Re-raise errors caught by the controller.
class ReleaseController; def rescue_action(e) raise e end; end

class ReleaseControllerTest < Test::Unit::TestCase
  fixtures :codes, :statuses, :items, :release_details, :role_security_profiles, :role_details

  def setup
    @controller = ReleaseController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @session = @request.session
    @user = Person.find(:first)
    @releases = Release.find(:all)
    @session[:person] = @user
    @session[:auth_cache] = Hash.new
    @session[:project_link_cache] = Hash.new
  end

  # Show all the test releases
  def test_show_each
    assert !@releases.empty?
    @releases.each do |r|
      get :show, :id => r.id
      assert_response :success
    end
  end
  
  def test_edit_new
    get :edit, { :project_id => @user.project_id }
    assert_response :success
    assert_template 'item/edit'
  end
  
  def test_edit_existing
    @releases.each do |r|
      get :edit, { :id => r.id }
      assert_response :success
    end
  end
end
