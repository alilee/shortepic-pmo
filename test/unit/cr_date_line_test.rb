require File.dirname(__FILE__) + '/../test_helper'

class CrDateLineTest < Test::Unit::TestCase
  fixtures :items, :cr_date_lines, :change_request_details
  
  # Simple test for addition of 1 valid record.
  def test_add_valid
    cd = CrDateLine.new
    cd.change_request = ChangeRequest.find_by_title('New change request')
    cd.milestone = Milestone.find_by_title('Father milestone')
    cd.start_on = '2006-10-01'
    cd.end_on = '2007-09-30'
    assert_valid cd
    assert cd.save
  end

  # Test validation of dates
  def test_valid_dates
    cd  = CrDateLine.new
    cd.change_request = ChangeRequest.find_by_title('New change request')
    cd.milestone = Milestone.find_by_title('Father milestone')
    cd.start_on = '2007-10-01'
    cd.end_on = '2007-09-30'    
    assert !cd.valid?
    assert_equal "should be after start", cd.errors.on(:end_on)
    cd.start_on = '2006-10-01'
    assert_valid cd
    assert cd.save
  end
  
  # Test that value is unique for the change request, milestone and role.
  def test_duplicate_cr_date_line_invalid
    cd = CrDateLine.new
    cd.change_request = ChangeRequest.find_by_title('New change request')
    cd.milestone = Milestone.find_by_title('Father milestone')
    cd.start_on = '2006-10-01'
    cd.end_on = '2007-09-30'
    assert_valid cd
    assert cd.save
    cd = CrDateLine.new
    cd.change_request = ChangeRequest.find_by_title('New change request')
    cd.milestone = Milestone.find_by_title('Father milestone')
    cd.start_on = '2007-10-01'
    cd.end_on = '2008-09-30'
    assert !cd.valid?
    cd1 = CrDateLine.new
    cd1.change_request = ChangeRequest.find_by_title('New change request')
    cd1.milestone = Milestone.find_by_title('Father milestone on track')
    cd1.start_on = '2007-10-01'
    cd1.end_on = '2008-09-30'
    assert_valid cd1
    assert cd1.save
  end
end
