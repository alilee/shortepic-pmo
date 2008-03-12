require File.dirname(__FILE__) + '/../test_helper'

class RoleTest < Test::Unit::TestCase
  fixtures :items, :role_details, :role_placements, :timesheet_lines, :timesheet_details, :cr_effort_lines, :statuses, :codes

  # Simple test for addition of 1 valid record.
  def test_add_valid
    r = Role.new
    r.title = 'Test role'
    r.parent = Project.find(:first)
    r.role = Role.find(:first)
    r.person = Person.find(:first)
    r.status = Status.find_by_type_name("Role")
    r.priority_code = Code.find_by_type_name_and_name("Role", "Priority")
    r.escalation = r.parent
    r.updated_by = r.person
    r.detail.security_profile_code = Code.find_by_type_name_and_name("Role","Security profile")
    assert_valid r.detail
    assert_valid r
    assert r.save
    r1 = Role.find_by_title('Test role')
    assert_not_nil r1
    r_detail1 = RoleDetail.find_by_role_id(r1.id)
    assert_not_nil r_detail1
  end
    
  # Test current person assignments are valid.
  def test_current_roles_are_valid
    r = Role.find_by_title('Root role')
    r_assign = RolePlacement.find_all_by_role_id(r.id, :conditions => 'now() between start_on and end_on')
    assert_equal(r_assign.size, r.current_role_placements.size)
  end  
  
  # Test timesheet summations returned are valid.
  # FIXME: A - fix tests for timesheet summations
=begin
  def test_actual_hours_are_valid
    r = Role.find_by_title('Root role')
    assert_not_nil r
    p = Person.find_by_title('Root person')
    assert_not_nil p
    t_line = TimesheetLine.find_by_sql(["
      SELECT
        DISTINCT td.person_id_worker, tl.milestone_id
      FROM
        timesheet_lines tl,
        timesheet_details td
      WHERE
        tl.timesheet_id = td.timesheet_id AND
        tl.role_id = ?",r.id])
      puts t_line.size
    assert_equal(2, t_line.size)
    normal_hours = TimesheetLine.sum :normal_hours,
      :conditions => ["timesheet_lines.role_id = ? and statuses.generic_stage = ?", r.id, Status::COMPLETE],
      :joins => "inner join items on timesheet_lines.timesheet_id = items.id inner join statuses on statuses.id = items.status_id"
    tl =  r.actuals_to_date
    assert_equal(normal_hours,tl[0]['normal_hours'].to_i)
    overtime_hours = TimesheetLine.sum :overtime_hours,
      :conditions => ["timesheet_lines.role_id = ? and statuses.generic_stage = ?", r.id, Status::COMPLETE],
      :joins => "inner join items on timesheet_lines.timesheet_id = items.id inner join statuses on statuses.id = items.status_id"
    assert_equal(overtime_hours.to_i,tl[0]['overtime_hours'].to_i)
    uncharged_hours = TimesheetLine.sum :uncharged_hours,
      :conditions => ["timesheet_lines.role_id = ? and statuses.generic_stage = ?", r.id, Status::COMPLETE],
      :joins => "inner join items on timesheet_lines.timesheet_id = items.id inner join statuses on statuses.id = items.status_id"
    assert_equal(uncharged_hours.to_i,tl[0]['uncharged_hours'].to_i)
    hours_estimated_to_complete = TimesheetLine.sum :hours_estimated_to_complete,
      :conditions => ["timesheet_lines.role_id = ? and statuses.generic_stage = ?", r.id, Status::COMPLETE],
      :joins => "inner join items on timesheet_lines.timesheet_id = items.id inner join statuses on statuses.id = items.status_id"
    assert_equal(hours_estimated_to_complete.to_i,tl[0]['hours_estimated_to_complete'].to_i)
  end
=end
end
