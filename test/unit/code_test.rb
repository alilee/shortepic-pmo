require File.dirname(__FILE__) + '/../test_helper'
 
class CodeTest < Test::Unit::TestCase
  fixtures :codes
  
  # Simple test for addition of 1 valid record.
  def test_add_valid
    code = Code.new
    code.type_name = 'Person'
    code.name = 'Sex'
    code.value = 'Female'
    assert_valid code
    assert code.save
  end

  # Test a duplicate code record cannot be inserted
  def test_reject_duplicate
    blocker = Code.find_by_type_name_and_name_and_value('Person','Contact', 'Mobile')
    assert !blocker.nil?
    code = Code.new
    code.type_name = 'Person'
    code.name = 'Contact'
    code.value = 'Mobile'
    assert !code.valid?
    assert !code.save
  end
  
end
