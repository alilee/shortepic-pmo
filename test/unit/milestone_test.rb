require File.dirname(__FILE__) + '/../test_helper'

class MilestoneTest < Test::Unit::TestCase
  fixtures :items, :milestone_details, :change_request_details, :cr_date_lines, :cr_effort_lines, :statuses, :codes
  
  # Simple test for addition of 1 valid record.
  def test_add_valid
    m = Milestone.new
    m.title = 'Test milestone'
    m.parent = Project.find(:first)
    m.role = Role.find(:first)
    m.person = Person.find(:first)
    m.status = Status.find_by_type_name("Milestone")
    m.priority_code = Code.find_by_type_name_and_name("Milestone", "Priority")
    m.escalation = m.parent
    m.updated_by = m.person
    assert_valid m
    assert m.save
    m1 = Milestone.find_by_title('Test milestone')
    m_detail = MilestoneDetail.find_by_milestone_id(m1.id)
    assert_not_nil m_detail
  end
  
  # Test that correct end date is returned from baseline_ends_on method.
  def test_baseline_ends_on_is_valid
    cr = ChangeRequest.new
    cr.title = 'New test change request'
    cr.parent = Project.find(:first)
    cr.role = Role.find(:first)
    cr.person = Person.find(:first)
    cr.status = Status.find_by_type_name_and_generic_stage("ChangeRequest",Status::COMPLETE)
    cr.priority_code = Code.find_by_type_name_and_name("ChangeRequest", "Priority")
    cr.escalation = cr.parent
    cr.updated_by = cr.person
    assert_valid cr
    assert cr.save
    cr_date = CrDateLine.new
    cr_date.change_request = ChangeRequest.find_by_title('New test change request')
    cr_date.milestone = Milestone.find(:first)
    cr_date.start_on = '2006-09-26'
    cr_date.end_on = '2006-12-24'
    assert_valid cr_date
    assert cr_date.save
    assert_equal(Date.parse('2006-12-24'),cr_date.milestone.baseline_ends_on)
  end
  
  # Test the correct number of effort lines are returned
  def test_approved_effort_lines_are_valid
    tested = false
    Milestone.find(:all).each do |m|
      cr_effort_lines = CrEffortLine.find_all_by_milestone_id(m.id, 
        :include => {:change_request => :status},
        :conditions => ['generic_stage = ?', Status::COMPLETE]
      )
      assert_equal m.approved_effort_lines.size, cr_effort_lines.size
      tested = true 
    end
    assert tested
  end
end
