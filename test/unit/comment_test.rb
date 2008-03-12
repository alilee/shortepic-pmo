require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < Test::Unit::TestCase
  fixtures :items, :comments

  # Simple test for addition of 1 valid record.
  def test_add_valid
    c = Comment.new
    c.item = Issue.find(:first)
    c.person = Person.find(:first)
    c.created_at = Time.now
    c.body = 'xxx'
    assert_valid c
    assert c.save
  end
    
end
