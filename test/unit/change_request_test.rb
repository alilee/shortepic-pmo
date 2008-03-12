require File.dirname(__FILE__) + '/../test_helper'

class ChangeRequestTest < Test::Unit::TestCase
  fixtures :items, :change_request_details, :statuses, :codes

  # Simple test for addition of 1 valid record.
  def test_add_valid
    cr = ChangeRequest.new
    cr.title = 'Test title'
    cr.parent = Project.find(:first)
    cr.role = Role.find(:first)
    cr.person = Person.find(:first)
    cr.status = Status.find_by_type_name("ChangeRequest")
    cr.priority_code = Code.find_by_type_name_and_name("ChangeRequest", "Priority")
    cr.escalation = cr.parent
    cr.updated_by = cr.person
    assert_valid cr
    assert cr.save
    cr1 = ChangeRequest.find_by_title('Test title')
    cr_detail = ChangeRequestDetail.find_by_change_request_id(cr1.id)
    assert_not_nil cr_detail
  end
end
