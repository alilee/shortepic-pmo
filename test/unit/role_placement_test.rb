require File.dirname(__FILE__) + '/../test_helper'

class RolePlacementTest < Test::Unit::TestCase
  fixtures :items, :role_placements

  # Simple test for addition of 1 valid record.
  def test_add_valid
    pa  = RolePlacement.new
    pa.person = Person.find(:first)
    pa.role = Role.find(:first)
    pa.start_on = '2006-09-01'
    pa.end_on = '2007-09-01'
    pa.committed_hours = 2000
    pa.normal_hourly_rate = 100
    assert pa.valid?
    assert pa.save
  end
  
  # Test committed hours are entered as a number and are positive
  def test_positive_committed_hours
    pa  = RolePlacement.new
    pa.person = Person.find(:first)
    pa.role = Role.find(:first)
    pa.start_on = '2006-09-01'
    pa.end_on = '2007-09-01'
    pa.committed_hours = -100
    assert !pa.valid?
    assert_equal "should not be negative", pa.errors.on(:committed_hours)
    pa.committed_hours = 'xxx'
    assert !pa.valid?
    pa.committed_hours = 0
    pa.normal_hourly_rate = 100
    assert_valid pa
    assert pa.save
  end
  
  # Test validation of dates
  def test_valid_dates
    pa  = RolePlacement.new
    pa.person = Person.find(:first)
    pa.role = Role.find(:first)
    pa.start_on = '2007-09-01'
    pa.end_on = '2006-09-01'
    pa.committed_hours = '100'
    assert !pa.valid?
    assert_equal "should be later than the start", pa.errors.on(:end_on)
    pa.normal_hourly_rate = 100
    pa.start_on = '2006-08-01'
    assert_valid pa
    assert pa.save
  end
  
  # Check that a duplicate person assignment cannot be entered.
  # TODO: B - test duplicate role placement invalid
  # def test_duplicate_role_placement_invalid
  # end

end
