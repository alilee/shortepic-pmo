require File.dirname(__FILE__) + '/../test_helper'

class PersonContactTest < Test::Unit::TestCase
  fixtures :items, :person_contacts, :codes
  
  # Simple test for addition of 1 valid record.
  def test_add_valid
    pc  = PersonContact.new
    pc.person = Person.find(:first)
    pc.contact_code = Code.find_by_type_name_and_name("Person","Contact")
    pc.address = 'xxx'
    assert_valid pc
    assert pc.save
  end

  # Test that an invalid code cannot be added.
  def test_valid_contact_code
    pc = PersonContact.new
    pc.person = Person.find(:first)
    pc.address = 'xxxxx' 
    pc.contact_code = Code.find_by_type_name("Role")
    assert !pc.valid?
    assert_equal "is not included in the list", pc.errors.on(:code_id_contact)
    pc.contact_code = Code.find_by_type_name_and_name("Person","Priority")
    assert !pc.valid?
    assert_equal "is not included in the list", pc.errors.on(:code_id_contact)
    pc.contact_code = Code.find_by_type_name_and_name("Person","Contact")
    assert_valid pc
    assert pc.save
  end

  # Test that value is unique for the contact code and person.
  def test_duplicate_person_contact_invalid 
    pc = PersonContact.new
    pc.person = Person.find(:first)
    pc.contact_code = Code.find_by_type_name_and_name_and_value("Person","Contact","Mobile")
    pc.address = 'xxx'
    assert_valid pc
    assert pc.save
    pc1 = PersonContact.new
    pc1.person = Person.find(:first)
    pc1.contact_code = Code.find_by_type_name_and_name_and_value("Person","Contact","Mobile")
    pc1.address = 'xxx'
    assert !pc1.valid?
    pc1 = PersonContact.new
    pc1.person = Person.find(:first)
    pc1.contact_code = Code.find_by_type_name_and_name_and_value("Person","Contact","Home phone")
    pc1.address = 'xxx'
    assert_valid pc1
    assert pc1.save
    pc2 = PersonContact.new
    pc2.person = Person.find(:first)
    pc2.contact_code = Code.find_by_type_name_and_name_and_value("Person","Contact","Mobile")
    pc2.address = 'yyy'
    assert_valid pc2
    assert pc2.save
  end
end
