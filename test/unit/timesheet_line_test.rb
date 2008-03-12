require File.dirname(__FILE__) + '/../test_helper'

class TimesheetLineTest < Test::Unit::TestCase
  fixtures :items, :timesheet_lines, :codes, :statuses

  # Simple test for addition of 1 valid record.
  def test_add_valid
    t = Timesheet.new
    t.title = 'Timesheet test'
    t.parent = Project.find(:first)
    t.role = Role.find(:first)
    t.person = Person.find(:first)
    t.status = Status.find_by_type_name("Timesheet")
    t.priority_code = Code.find_by_type_name_and_name("Timesheet", "Priority")
    t.escalation = t.parent
    t.updated_by = t.person
    t.detail.period_ending_on = Date.today
    t.detail.person_id_worker = Person.find(:first)
    assert_valid t.detail
    assert_valid t
    assert t.save
    tl = TimesheetLine.new
    tl.timesheet = Timesheet.find_by_title("Timesheet test")
    tl.milestone = Milestone.find(:first)
    tl.role = Role.find(:first)
    tl.worked_on = '2006-10-05'
    tl.normal_hours = 20
    assert tl.valid?
    assert tl.save
  end

  # Test that invalid hours cannot be entered.
  def test_valid_hours
    t = Timesheet.new
    t.title = 'Timesheet test'
    t.parent = Project.find(:first)
    t.role = Role.find(:first)
    t.person = Person.find(:first)
    t.status = Status.find_by_type_name("Timesheet")
    t.priority_code = Code.find_by_type_name_and_name("Timesheet", "Priority")
    t.escalation = t.parent
    t.updated_by = t.person
    t.detail.period_ending_on = Date.today
    t.detail.person_id_worker = Person.find(:first)
    assert_valid t.detail
    assert_valid t
    assert t.save    
    tl = TimesheetLine.new
    tl.timesheet = Timesheet.find_by_title("Timesheet test")
    tl.milestone = Milestone.find(:first)
    tl.role = Role.find(:first)
    tl.worked_on = '2006-10-05'
    tl.normal_hours = -1
    assert !tl.valid?
    assert_equal "should be between 0 and 168", tl.errors.on(:normal_hours)
    tl.normal_hours = 0
    tl.overtime_hours = -1
    assert !tl.valid?
    assert_equal "should be between 0 and 168", tl.errors.on(:overtime_hours)
    tl.overtime_hours = 0
    tl.uncharged_hours = -1
    assert !tl.valid?
    assert_equal "should be between 0 and 168", tl.errors.on(:uncharged_hours)
    tl.uncharged_hours = 0
    assert tl.valid?
    assert tl.save
  end
  
  # Check that a duplicate timesheet line cannot be entered.
  def test_duplicate_timesheet_line_invalid
    t = Timesheet.new
    t.title = 'Timesheet test'
    t.parent = Project.find(:first)
    t.role = Role.find(:first)
    t.person = Person.find(:first)
    t.status = Status.find_by_type_name("Timesheet")
    t.priority_code = Code.find_by_type_name_and_name("Timesheet", "Priority")
    t.escalation = t.parent
    t.updated_by = t.person
    t.detail.period_ending_on = Date.today
    t.detail.person_id_worker = Person.find(:first)
    assert_valid t.detail
    assert_valid t
    assert t.save    
    tl = TimesheetLine.new
    tl.timesheet = Timesheet.find(:first)
    tl.milestone = Milestone.find(:first)
    tl.role = Role.find(:first)
    tl.worked_on = '2006-10-05'
    tl.normal_hours = 20
    assert_valid tl
    assert tl.save
    tl1 = TimesheetLine.new
    tl1.timesheet = Timesheet.find(:first)
    tl1.milestone = Milestone.find(:first)
    tl1.role = Role.find(:first)
    tl1.worked_on = '2006-10-05'
    tl1.normal_hours = 20
    assert !tl1.valid?
  end
  
end
