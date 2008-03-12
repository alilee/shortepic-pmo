require File.dirname(__FILE__) + '/../test_helper'

class StatusTest < Test::Unit::TestCase
  fixtures :statuses

  # Simple test for addition of 1 valid record.
  def test_add_valid
    s = Status.new
    s.type_name = 'Issue'
    s.value = 'New'
    s.generic_stage = '1-new'
    assert s.valid?
    assert s.save
  end
  
  # Test that an invalid type name cannot be added.
  def test_valid_type_name
    s = Status.new
    s.value = 'New'
    s.generic_stage = '1-new'
    s.type_name = 'Defect'
    assert !s.valid?
    s.type_name = 'Issue'
    assert s.valid?
    assert s.save
  end

  # Test that an invalid generic_stage cannot be added.
  def test_valid_generic_stage
    s = Status.new
    s.type_name = 'Issue'
    s.value = 'New'
    s.generic_stage = '7-cancel'
    assert !s.valid?
    s.generic_stage = '1-new'
    assert s.valid?
    assert s.save
  end
  
  # Test a duplicate status record cannot be inserted
  def test_duplicate_status_invalid
    s = Status.new
    s.type_name = 'Issue'
    s.value = 'New'
    s.generic_stage = '1-new'
    assert s.valid?
    assert s.save
    s1 = Status.new
    s1.type_name = 'Issue'
    s1.value = 'New'
    s1.generic_stage = '1-new'    
    assert !s1.valid?
    s1.value = 'Create'
    assert s1.valid?
    assert s1.save
    s2 = Status.new
    s2.type_name = 'ChangeRequest'
    s2.value = 'New'
    s2.generic_stage = '1-new'
    assert s2.valid?
    assert s2.save
  end
  
end
