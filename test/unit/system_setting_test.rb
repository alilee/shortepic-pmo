require File.dirname(__FILE__) + '/../test_helper'

class SystemSettingTest < Test::Unit::TestCase
  fixtures :system_settings

  # Simple test for addition of 1 valid record.
  def test_add_valid
    s = SystemSetting.new
    s.name = 'Test system setting'
    s.category = 'Links'
    assert s.valid?
    assert s.save
  end

  # Test a duplicate system setting record cannot be inserted
  def test_duplicate_system_setting_invalid
    s = SystemSetting.new
    s.name = 'Test system setting'
    s.category = 'Links'
    assert s.valid?
    assert s.save
    s1 = SystemSetting.new
    s1.name = 'Test system setting'
    s1.category = 'Links'
    assert !s1.valid?
    s1.category = 'Traffic lights'
    assert s1.valid?
    assert s1.save
    s2 = SystemSetting.new
    s2.name = 'System setting'
    s2.category = 'Links'
    assert s2.valid?
    assert s2.save
  end

end
