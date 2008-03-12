require File.dirname(__FILE__) + '/../test_helper'
require 'test_condition_controller'

# Re-raise errors caught by the controller.
class TestConditionController; def rescue_action(e) raise e end; end

class TestConditionControllerTest < Test::Unit::TestCase
  def setup
    @controller = TestConditionController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
