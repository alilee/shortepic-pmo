require File.dirname(__FILE__) + '/../test_helper'
require 'sales_lead_controller'

# Re-raise errors caught by the controller.
class SalesLeadController; def rescue_action(e) raise e end; end

class SalesLeadControllerTest < Test::Unit::TestCase
  fixtures :codes, :statuses, :items, :sales_lead_details, :role_placements, :role_security_profiles, :role_details, :status_transitions
  
  def setup
    @controller = SalesLeadController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @session = @request.session
    @user = Person.find(:first)
    @salesleads = SalesLead.find(:all) || []
    @session[:person] = @user
    @session[:auth_cache] = Hash.new
    @session[:project_link_cache] = Hash.new
  end

  def test_there_are_some_test_data_in_fixture
    assert_equal 2, @salesleads.size
  end
  
  def test_display_every_sales_lead_in_show_view
    @salesleads.each { |i|
      get :show, { :id => i.id }
      assert_response :success
    }
  end
  
  def test_display_every_sales_lead_in_edit_view
    @salesleads.each { |i|
      get :edit, { :id => i.id }
      assert_response :success
    }
  end
  
  def test_edit_and_save
    ai = @salesleads.first
    get :edit, { :id => ai.id }
    item = assigns["item"]
    assert_equal ai.description, item.description

    item.description = 'foo bar'
    post :edit, { :id => ai.id, :item => item.attributes, :detail => item.detail.attributes }
    assert_response :success
    assert_equal 'foo bar', SalesLead.find(ai.id).description
  end
  
  def test_new
    get :edit, { :project_id => Project.find(:first).id }
    assert_response :success
  end
  
  def test_list
    get :list, {}
    assert_response :success
  end
  
end
