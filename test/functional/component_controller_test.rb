require File.dirname(__FILE__) + '/../test_helper'
require 'component_controller'

# Re-raise errors caught by the controller.
class ComponentController; def rescue_action(e) raise e end; end

class ComponentControllerTest < Test::Unit::TestCase
  fixtures :codes, :statuses, :items, :component_details, :role_security_profiles, :role_details

  def setup
    @controller = ComponentController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @session = @request.session
    @user = Person.find(:first)
    @components = Component.find(:all)
    @session[:person] = @user
    @session[:auth_cache] = Hash.new
    @session[:project_link_cache] = Hash.new
  end

  # Show all the test components
  def test_show_each
    assert !@components.empty?
    @components.each do |c|
      get :show, :id => c.id
      assert_response :success
    end
  end
  
  def test_edit_new
    get :edit, { :project_id => @user.project_id }
    assert_response :success
    assert_template 'item/edit'
  end
  
  def test_edit_existing
    @components.each do |c|
      get :edit, { :id => c.id }
      assert_response :success
    end
  end
  
  # display the components and sub-assemblies within a sub-assembly
  def test_show_nha
    assert true
  end
  
  def test_show_pbs
    assert true
  end
  
end
