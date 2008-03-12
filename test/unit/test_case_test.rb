require File.dirname(__FILE__) + '/../test_helper'

class TestCaseTest < Test::Unit::TestCase
  fixtures :items, :test_case_details, :statuses, :codes

  # Simple test for addition of 1 valid record.
  def test_add_valid
    t = TestCase.new
    t.title = 'Test requirement'
    t.parent = Project.find(:first)
    t.role = Role.find(:first)
    t.person = Person.find(:first)
    t.status = Status.find_by_type_name("TestCase")
    t.priority_code = Code.find_by_type_name_and_name("TestCase", "Priority")
    t.escalation = t.parent
    t.updated_by = t.person
    t.detail.milestone_id_preparation = Milestone.find(:first)
    t.detail.milestone_id_execution = Milestone.find(:first)
    assert_valid t
    assert t.save
    t1 = TestCase.find_by_title(t.title)
    t_detail = TestCaseDetail.find_by_test_case_id(t1.id)
    assert_not_nil t_detail
  end
end
