require File.dirname(__FILE__) + '/../test_helper'

class IssueTest < Test::Unit::TestCase
  fixtures :items, :issue_details, :statuses, :codes

  # Simple test for addition of 1 valid record.
  def test_add_valid
    i = Issue.new
    i.title = 'Test issue'
    i.parent = Project.find(:first)
    i.role = Role.find(:first)
    i.person = Person.find(:first)
    i.status = Status.find_by_type_name("Issue")
    i.priority_code = Code.find_by_type_name_and_name("Issue", "Priority")
    i.escalation = i.parent
    i.updated_by = i.person
    assert_valid i
    assert i.save
    i1 = Issue.find_by_title('Test issue')
    i_detail = IssueDetail.find_by_issue_id(i1.id)
    assert_not_nil i_detail
  end
end
