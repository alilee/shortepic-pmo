require File.dirname(__FILE__) + '/../test_helper'

class SubscriptionTest < Test::Unit::TestCase
  fixtures :items, :subscriptions

  # Simple test for addition of 1 valid record.
  def test_add_valid
    s = Subscription.new
    s.item = Milestone.find(:first)
    s.person = Person.find(:first)
    assert s.valid?
    assert s.save
  end
  
  # Test that value is unique for the subscription.
  def test_duplicate_subscription_invalid
    s = Subscription.new
    s.item = Milestone.find(:first)
    s.person = Person.find(:first)
    assert s.valid?
    assert s.save
    s1 = Subscription.new
    s1.item = Milestone.find(:first)
    s1.person = Person.find(:first)
    assert !s1.valid?
    s1.item = Milestone.find(:first)
    s1.person = Person.find(:first, :conditions => ['id <> ?', Person.find(:first).id])
    assert_valid s1
    assert s1.save
  end  
end
