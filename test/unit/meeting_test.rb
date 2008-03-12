require File.dirname(__FILE__) + '/../test_helper'

class MeetingTest < Test::Unit::TestCase
  fixtures :items, :meeting_details, :meeting_attendees, :statuses, :codes
  
  # Simple test for addition of 1 valid record.
  def test_add_valid
    m = Meeting.new
    m.title = 'Test title'
    m.parent = Project.find(:first)
    m.role = Role.find(:first)
    m.person = Person.find(:first)
    m.status = Status.find_by_type_name_and_enabled("Meeting", true)
    m.priority_code = Code.find_by_type_name_and_name("Meeting", "Priority")
    m.escalation = m.parent
    m.updated_by = m.person
    m.detail.location = 'meeting room'
    assert_valid m
    assert m.save
    m1 = Meeting.find_by_title('Test title')
    assert_not_nil m1
    m_detail = MeetingDetail.find_by_meeting_id(m1.id)
    assert_not_nil m_detail
  end
end