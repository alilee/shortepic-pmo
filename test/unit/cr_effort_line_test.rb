require File.dirname(__FILE__) + '/../test_helper'

class CrEffortLineTest < Test::Unit::TestCase
  fixtures :items, :cr_effort_lines

  # Simple test for addition of 1 valid record.
  def test_add_valid
    ce = CrEffortLine.new
    ce.change_request = ChangeRequest.find_by_title("Father change request")
    ce.milestone = Milestone.find_by_title("Father milestone")
    ce.role = Role.find_by_title("Pending role")
    ce.hours = 1200
    ce.effort_budget = 32000
    assert_valid ce
    assert ce.save
  end
  
  # Test that invalid hours cannot be entered.
  def test_valid_hours
    ce = CrEffortLine.new
    ce.change_request = ChangeRequest.find_by_title("Father change request")
    ce.milestone = Milestone.find_by_title("Father milestone")
    ce.role = Role.find_by_title("Pending role")
    ce.hours = -1
    ce.effort_budget = 0
    assert !ce.valid?
    assert_equal "should be positive", ce.errors.on(:hours)
    ce.hours = 0
    ce.effort_budget = -1
    assert !ce.valid?
    assert_equal "should be positive", ce.errors.on(:effort_budget)
    ce.hours = 1200
    ce.effort_budget = 32000
    assert_valid ce
    assert ce.save    

  end
  
  # Check that a duplicate effort line cannot be entered.
  def test_duplicate_cr_effort_line_invalid
    ce = CrEffortLine.new
    ce.change_request = ChangeRequest.find_by_title("Test change request")
    ce.milestone = Milestone.find_by_title("Father milestone")
    ce.role = Role.find_by_title("Father role")
    ce.hours = 1200
    ce.effort_budget = 32000
    assert_valid ce
    assert ce.save
    ce1 = CrEffortLine.new
    ce1.change_request = ChangeRequest.find_by_title("Test change request")
    ce1.milestone = Milestone.find_by_title("Father milestone")
    ce1.role = Role.find_by_title("Father role")
    ce1.hours = 0
    ce1.effort_budget = 0
    assert !ce1.valid?    
    ce2 = CrEffortLine.new
    ce2.change_request = ChangeRequest.find_by_title("Test change request")
    ce2.milestone = Milestone.find_by_title("Father milestone")
    ce2.role = Role.find_by_title("Pending role")
    ce2.hours = 0
    ce2.effort_budget = 0
    assert_valid ce2    
    assert ce2.save
    ce3 = CrEffortLine.new
    ce3.change_request = ChangeRequest.find_by_title("Test change request")
    ce3.milestone = Milestone.find_by_title("Father milestone on track")
    ce3.role = Role.find_by_title("Father role")
    ce3.hours = 0
    ce3.effort_budget = 0
    assert_valid ce3    
    assert ce3.save
  end
end
