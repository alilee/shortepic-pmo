require File.dirname(__FILE__) + '/../test_helper'

class AssociationTest < Test::Unit::TestCase
  fixtures :items, :associations
  
  # Simple test for addition of 1 valid record.
  def test_add_valid
    a = Association.new
    a.item_from = Issue.find(:first)
    a.item_to = ActionItem.find(:first)
    assert_valid a
    assert a.save
  end
  
  # Test that value is unique for the associated items.
  def test_duplicate_association_invalid
    l1 = Issue.find(:first)
    l2 = ActionItem.find(:first)
    a = Association.new
    a.item_from = l1
    a.item_to = l2
    assert_valid a
    assert a.save
    a1 = Association.new
    a1.item_from = l1
    a1.item_to = l2
    assert !a1.valid?
  end
end
