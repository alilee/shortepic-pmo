require File.dirname(__FILE__) + '/../test_helper'

class CrExpenseLineTest < Test::Unit::TestCase
  fixtures :items, :cr_expense_lines, :codes
  
  # Simple test for addition of 1 valid record.
  def test_add_valid
    ce = CrExpenseLine.new
    ce.change_request = ChangeRequest.find_by_title("Test change request")
    ce.milestone = Milestone.find_by_title("Father milestone")
    ce.role = Role.find_by_title("Father role")
    ce.purpose_code = Code.find_by_type_name_and_name("ChangeRequest","Purpose")
    ce.expense_budget = 10000
    assert_valid ce
    assert ce.save
  end
  
  # Test that invalid amount for expense budget cannot be entered.
  def test_valid_expense_budget
    ce = CrExpenseLine.new
    ce.change_request = ChangeRequest.find_by_title("Test change request")
    ce.milestone = Milestone.find_by_title("Father milestone")
    ce.role = Role.find_by_title("Father role")
    ce.purpose_code = Code.find_by_type_name_and_name("ChangeRequest","Purpose")
    ce.expense_budget = -1
    assert !ce.valid?
    assert_equal "should not be negative", ce.errors.on(:expense_budget)
    ce.expense_budget = 0
    assert_valid ce
    assert ce.save
  end
  
  # Check that a duplicate expense line cannot be entered.
  def test_duplicate_cr_expense_line_invalid
    ce = CrExpenseLine.new
    ce.change_request = ChangeRequest.find_by_title("Test change request")
    ce.milestone = Milestone.find_by_title("Father milestone")
    ce.role = Role.find_by_title("Father role")
    ce.purpose_code = Code.find_by_type_name_and_name("ChangeRequest","Purpose")
    ce.expense_budget = 10000
    assert_valid ce
    assert ce.save
    ce1 = CrExpenseLine.new
    ce1.change_request = ChangeRequest.find_by_title("Test change request")
    ce1.milestone = Milestone.find_by_title("Father milestone")
    ce1.role = Role.find_by_title("Father role")
    ce1.purpose_code = Code.find_by_type_name_and_name("ChangeRequest","Purpose")
    ce1.expense_budget = 0
    assert !ce1.valid?   
    ce2 = CrExpenseLine.new
    ce2.change_request = ChangeRequest.find_by_title("Test change request")
    ce2.milestone = Milestone.find_by_title("Father milestone")
    ce2.role = Role.find_by_title("Pending role")
    ce2.purpose_code = Code.find_by_type_name_and_name("ChangeRequest","Purpose")
    ce2.expense_budget = 0
    assert_valid ce2    
    assert ce2.save
    ce3 = CrExpenseLine.new
    ce3.change_request = ChangeRequest.find_by_title("Test change request")
    ce3.milestone = Milestone.find_by_title("Father milestone on track")
    ce3.role = Role.find_by_title("Father role")
    ce3.purpose_code = Code.find_by_type_name_and_name("ChangeRequest","Purpose")
    ce3.expense_budget = 0
    assert_valid ce3    
    assert ce3.save
  end
  
  # Test that an invalid code cannot be added.
  def test_valid_purpose_code
    ce = CrExpenseLine.new
    ce.change_request = ChangeRequest.find_by_title("Test change request")
    ce.milestone = Milestone.find_by_title("Father milestone")
    ce.role = Role.find_by_title("Father role")
    ce.expense_budget = 10000
    ce.purpose_code = Code.find_by_type_name("Timesheet")
    assert !ce.valid?
    assert_equal "is not included in the list", ce.errors.on(:code_id_purpose)
    ce.purpose_code = Code.find_by_type_name_and_name("ChangeRequest","Priority")
    assert !ce.valid?
    assert_equal "is not included in the list", ce.errors.on(:code_id_purpose)
    ce.purpose_code = Code.find_by_type_name_and_name("ChangeRequest","Purpose")
    assert_valid ce
    assert ce.save
  end
  
end
