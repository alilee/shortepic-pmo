require File.dirname(__FILE__) + '/../test_helper'

class TimesheetTest < Test::Unit::TestCase
  fixtures :items, :timesheet_details, :codes, :statuses

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
    assert !t.detail.valid?
    assert !t.valid?
    t.detail.period_ending_on = Date.today
    t.detail.person_id_worker = Person.find(:first)
    assert_valid t.detail
    assert_valid t
    assert t.save
    t1 = Timesheet.find_by_title('Timesheet test')
    assert_not_nil t1
    t_detail1 = TimesheetDetail.find_by_timesheet_id(t1.id)
    assert_not_nil t_detail1
  end  
end
