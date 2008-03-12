require File.dirname(__FILE__) + '/../test_helper'
require 'item_controller'

# Re-raise errors caught by the controller.
class ItemController; def rescue_action(e) raise e end; end

# The item update tests are in Person.
# The item association tests are in Issue.
# The item change validation tests (including status transition) are in Role.
# Signature tests are in MilestoneControllerTest
class ItemControllerTest < Test::Unit::TestCase
  fixtures :items, :codes, :statuses, :person_details
  
  def setup
    @controller = ItemController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @session = @request.session
    @user = Person.find(:first)
    @issues = Issue.find(:all)
    @session[:person] = @user
    @session[:auth_cache] = Hash.new
  end
  
  def test_true
  end
  
  # TODO: C - authorised people from root project
    
end
