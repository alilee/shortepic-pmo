require File.dirname(__FILE__) + '/../test_helper'

class TestConditionTest < Test::Unit::TestCase
  fixtures :items, :test_condition_details, :statuses, :codes

  # Simple test for addition of 1 valid record.
  def test_add_valid
    t = TestCondition.new
    t.title = 'Test condition'
    t.parent = Project.find(:first)
    t.role = Role.find(:first)
    t.person = Person.find(:first)
    t.status = Status.find_by_type_name("TestCondition")
    t.priority_code = Code.find_by_type_name_and_name("TestCondition", "Priority")
    t.escalation = t.parent
    t.updated_by = t.person
    t.detail.milestone_id_phase_covered = Milestone.find(:first)
    t.detail.code_id_type = Code.find_by_type_name_and_name("TestCondition", "Type")
    assert_valid t.detail
    assert_valid t
    assert t.save
    t1 = TestCondition.find_by_title(t.title)
    t_detail = TestConditionDetail.find_by_test_condition_id(t1.id)
    assert_not_nil t_detail
  end
end
