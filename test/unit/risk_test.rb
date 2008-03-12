require File.dirname(__FILE__) + '/../test_helper'

class RiskTest < Test::Unit::TestCase
  fixtures :items, :risk_details, :statuses, :codes

  # Simple test for addition of 1 valid record.
  def test_add_valid
    r = Risk.new
    r.title = 'Test risk'
    r.parent = Project.find(:first)
    r.role = Role.find(:first)
    r.person = Person.find(:first)
    r.status = Status.find_by_type_name("Risk")
    r.priority_code = Code.find_by_type_name_and_name("Risk", "Priority")
    r.escalation = r.parent
    r.updated_by = r.person
    assert_valid r
    assert r.save
    r1 = Risk.find_by_title('Test risk')
    r_detail = RiskDetail.find_by_risk_id(r1.id)
    assert_not_nil r_detail
  end
end
