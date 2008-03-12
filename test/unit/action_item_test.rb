require File.dirname(__FILE__) + '/../test_helper'

class ActionItemTest < Test::Unit::TestCase
  fixtures :items, :action_item_details, :statuses, :codes

  # Simple test for addition of 1 valid record.
  def test_add_valid
    a = ActionItem.new
    a.title = 'Test action item'
    a.parent = Project.find(:first)
    a.role = Role.find(:first)
    a.person = Person.find(:first)
    a.status = Status.find_by_type_name("ActionItem")
    a.priority_code = Code.find_by_type_name_and_name("ActionItem", "Priority")
    a.escalation = a.parent
    a.updated_by = a.person 
    a.detail.code_id_environment = Code.find_by_type_name_and_name("ActionItem", "Environment")
    a.save!
    a1 = ActionItem.find_by_title('Test action item')
    a_detail = ActionItemDetail.find_by_action_item_id(a1.id)
    assert_not_nil a_detail
  end
  
end