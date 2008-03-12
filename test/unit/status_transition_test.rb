require File.dirname(__FILE__) + '/../test_helper'

class StatusTransitionTest < Test::Unit::TestCase
  fixtures :status_transitions, :codes

  # Replace this with your real tests.
  def test_create_and_save
    s = StatusTransition.new
    s.type_name = 'StatusReport'
    s.status_from = Status.find_by_type_name(s.type_name)
    s.status_to = Status.find_by_type_name(s.type_name, :conditions => ['id <> ?', s.status_from.id])
    s.security_profile_code = Code.find_by_type_name_and_name('Role', 'Security profile')
    assert_valid s
  end
  
end
