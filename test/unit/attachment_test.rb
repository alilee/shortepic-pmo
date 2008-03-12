require File.dirname(__FILE__) + '/../test_helper'

class AttachmentTest < Test::Unit::TestCase
  # fixtures :attachments

  # TODO: C - create separate test cases for this method.
  def test_attachments
    a = Attachment.new
    #Blank Save
    a.save
    assert_equal 6, a.errors.count
    assert a.errors.full_messages.member?("Filename can't be blank")

    #Only Filename Known and FileSize = 0
    a.filename = '/home/user/filename.txt'
    a.version = ""
    a.size = 0
    a.save
    assert_equal 5, a.errors.count
    assert a.errors.full_messages.member?('Size is reserved')

    a.size = 1000
    a.save
    assert_equal 4, a.errors.count
    assert a.errors.full_messages.member?('Version is too short (minimum is 1 characters)')
    
    a.version = "1.0"
    a.save
    assert_equal 3, a.errors.count
    assert a.errors.full_messages.member?("Mime type can't be blank")

    a.mime_type = "text/plain"
    a.save
    assert_equal 2, a.errors.count
    assert a.errors.full_messages.member?("Person can't be blank")
    
    a.person_id = 0
    a.save
    assert_equal 1, a.errors.count
    assert a.errors.full_messages.member?("Item can't be blank")
    
    a.item_id = 0
    # All info available
    assert_valid a
    assert a.save

    # Duplicating a record with same version
    b = Attachment.new
    b.filename = a.filename
    b.version = a.version
    b.size = a.size
    b.mime_type = a.mime_type
    b.item_id = a.item_id
    b.person_id = a.person_id
    b.save
    assert_equal 1, b.errors.count
    assert b.errors.full_messages.member?('Version already available. Please upload a new version of the file.')
  end
  
  # Test formatted file size is correct
  # Test that attributes from file are uploaded correctly.  Include test that attachment content populated correctly?
  
end
