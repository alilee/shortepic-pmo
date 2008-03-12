require File.dirname(__FILE__) + '/../test_helper'

class AbsenceTest < Test::Unit::TestCase
  fixtures :items, :absence_details, :codes, :statuses

  # Simple test for addition of 1 valid record.
  def test_add_valid
    a = Absence.new
    a.title = 'Test absence'
    a.parent = Project.find(:first)
    a.role = Role.find(:first)
    a.person = Person.find(:first)
    a.status = Status.find_by_type_name("Absence")
    a.priority_code = Code.find_by_type_name_and_name("Absence", "Priority")
    a.escalation = a.parent
    a.updated_by = a.person 
    a.detail.person = Person.find(:first)
    a.detail.away_on = Date.today
    a.detail.back_on = Date.today
    a.detail.availability_code = Code.find_by_type_name_and_name("Absence", "Availability")
    #assert_valid a.detail
    assert_valid a
    assert a.save
    a1 = Item.find_by_title('Test absence')
    a_detail = AbsenceDetail.find_by_absence_id(a1.id)
    assert_not_nil a_detail
  end
end
