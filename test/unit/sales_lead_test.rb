require File.dirname(__FILE__) + '/../test_helper'

class SalesLeadTest < Test::Unit::TestCase
  fixtures :items, :sales_lead_details, :statuses, :codes

  # Simple test for addition of 1 valid record.
  def test_add_valid
    a = SalesLead.new
    a.title = 'Test sales lead'
    a.parent = Project.find(:first)
    a.role = Role.find(:first)
    a.person = Person.find(:first)
    a.status = Status.find_by_type_name("SalesLead")
    a.priority_code = Code.find_by_type_name_and_name("SalesLead", "Priority")
    a.escalation = a.parent
    a.updated_by = a.person 
    a.detail.notes = "some notes"
    a.detail.client = "prospective client"
    a.save!
    a1 = SalesLead.find_by_title('Test sales lead')
    a_detail = SalesLeadDetail.find_by_sales_lead_id(a1.id)
    assert_not_nil a_detail
  end
  
end