require File.dirname(__FILE__) + '/../test_helper'
require 'status_report_controller'

# Re-raise errors caught by the controller.
class StatusReportController; def rescue_action(e) raise e end; end

class StatusReportControllerTest < Test::Unit::TestCase
  
  fixtures :codes, :statuses, :items, :status_report_details, :role_security_profiles, :role_details
  
  def setup
    @controller = StatusReportController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @session = @request.session
    @user = Person.find(:first)
    @status_reports = StatusReport.find(:all) || []
    @session[:person] = @user
    @session[:auth_cache] = Hash.new
    @session[:project_link_cache] = Hash.new
  end

  def test_show
    @status_reports.each { |status_report|
      get :show, { :id => status_report.id }
      assert_response :success
    }
  end
  
  def test_edit
    @status_reports.each { |status_reports|
      get :edit, { :id => status_reports.id }
      assert_response :success
    }
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
