require File.dirname(__FILE__) + '/../test_helper'

class SignatureTest < Test::Unit::TestCase
  fixtures :items, :signatures, :statuses

  # Simple test for addition of 1 valid record.
  def test_add_valid
    s = Signature.new
    s.item = ChangeRequest.find_by_title("Father change request")
    s.person = Person.find_by_title("Root person")
    s.status = Status.find_by_type_name("ChangeRequest")
    assert s.valid?
    assert s.save
  end
  
  # Check that a duplicate signature cannot be entered.
  def test_duplicate_signature_invalid
    s = Signature.new
    s.item = ChangeRequest.find_by_title("Father change request")
    s.person = Person.find_by_title("Root person")
    s.status = Status.find_by_type_name_and_value("ChangeRequest","3-in progress")
    assert s.valid?
    assert s.save
    s1 = Signature.new
    s1.item = ChangeRequest.find_by_title("Father change request")
    s1.person = Person.find_by_title("Root person")
    s1.status = Status.find_by_type_name_and_value("ChangeRequest","3-in progress")
    assert !s1.valid?
    s2 = Signature.new
    s2.item = ChangeRequest.find_by_title("Father change request")
    s2.person = Person.find_by_title("Root person")
    s2.status = Status.find_by_type_name_and_value("ChangeRequest","6-withdrawn")
    assert s2.valid?
    assert s2.save
    s3 = Signature.new
    s3.item = ChangeRequest.find_by_title("Father change request")
    s3.person = Person.find_by_title("Root person")
    s3.status = Status.find_by_type_name_and_value("ChangeRequest","5-complete")
    assert s3.valid?
    assert s3.save
    s4 = Signature.new
    s4.item = ChangeRequest.find_by_title("Father change request")
    s4.person = Person.find_by_title("Root person")
    s4.status = Status.find_by_type_name_and_value("ChangeRequest","5-complete")
    assert !s4.valid?
  end
  
  # Test that an invalid status cannot be added.
  def test_valid_status_code
    s = Signature.new
    s.item = ChangeRequest.find_by_title("Father change request")
    s.person = Person.find_by_title("Root person")
    s.status = Status.find_by_type_name_and_value("Role","1-new")
    assert !s.valid?
    assert_equal "is not included in the list", s.errors.on(:status_id)
    s.status = Status.find_by_type_name_and_value("Role","3-in progress")
    assert !s.valid?
    assert_equal "is not included in the list", s.errors.on(:status_id)    
    s.status = Status.find_by_type_name("ChangeRequest")
    assert s.valid?
    assert s.save
  end
  
end
