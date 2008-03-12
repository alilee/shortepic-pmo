require File.dirname(__FILE__) + '/../test_helper'

class StatusreportLineTest < Test::Unit::TestCase
  fixtures :items, :status_report_details, :status_report_lines, :codes, :statuses
     
  # Simple test for addition of 1 valid record.
  def test_add_valid
    sr = StatusReport.new
    sr.title = 'Status report test'
    sr.parent = Project.find(:first)
    sr.role = Role.find(:first)
    sr.person = Person.find(:first)
    sr.status = Status.find_by_type_name("StatusReport")
    sr.priority_code = Code.find_by_type_name_and_name("StatusReport","Priority")
    sr.escalation = sr.parent
    sr.updated_by = sr.person
    sr.detail.period_ending_on = '2006-10-31'
    sr.detail.traffic_code = Code.find_by_type_name_and_name("StatusReport","Traffic")
    sr.detail.achievements = "test achievement text"
    sr.detail.support_required = "test support reqd text"
    assert_valid sr.detail
    assert_valid sr
    assert sr.save
    sr_line = StatusReportLine.new
    sr_line.status_report = StatusReport.find_by_title("Status report test")
    sr_line.milestone = Milestone.find(:first)
    sr_line.percent_complete = 50
    sr_line.traffic_code = Code.find_by_type_name_and_name("StatusReport","Traffic")
    assert_valid sr_line
    assert sr_line.save
  end
  
  # Test that percent_complete is valid.
  def test_valid_percent_complete
    sr = StatusReport.new
    sr.title = 'Status report test'
    sr.parent = Project.find(:first)
    sr.role = Role.find(:first)
    sr.person = Person.find(:first)
    sr.status = Status.find_by_type_name("StatusReport")
    sr.priority_code = Code.find_by_type_name_and_name("StatusReport","Priority")
    sr.escalation = sr.parent
    sr.updated_by = sr.person
    sr.detail.period_ending_on = '2006-10-31'
    sr.detail.traffic_code = Code.find_by_type_name_and_name("StatusReport","Traffic")
    sr.detail.achievements = "test achievement text"
    sr.detail.support_required = "test support reqd text"
    assert_valid sr.detail
    assert_valid sr
    assert sr.save
    sr_line = StatusReportLine.new
    sr_line.status_report = StatusReport.find_by_title("Status report test")
    sr_line.milestone = Milestone.find(:first)
    sr_line.traffic_code = Code.find_by_type_name_and_name("StatusReport","Traffic")    
    sr_line.percent_complete = -10
    assert !sr_line.valid?
    assert_equal "should be between 0 and 100", sr_line.errors.on(:percent_complete)
    sr_line.percent_complete = 110
    assert !sr_line.valid?
    assert_equal "should be between 0 and 100", sr_line.errors.on(:percent_complete)
    sr_line.percent_complete = 50
    assert sr_line.valid?
    assert sr_line.save
  end
  
  # Test that estimated_hours_to_complete is valid.
  def test_valid_hours
    sr = StatusReport.new
    sr.title = 'Status report test'
    sr.parent = Project.find(:first)
    sr.role = Role.find(:first)
    sr.person = Person.find(:first)
    sr.status = Status.find_by_type_name("StatusReport")
    sr.priority_code = Code.find_by_type_name_and_name("StatusReport","Priority")
    sr.escalation = sr.parent
    sr.updated_by = sr.person
    sr.detail.period_ending_on = '2006-10-31'
    sr.detail.traffic_code = Code.find_by_type_name_and_name("StatusReport","Traffic")
    sr.detail.achievements = "test achievement text"
    sr.detail.support_required = "test support reqd text"
    assert_valid sr.detail
    assert_valid sr
    assert sr.save
    sr_line = StatusReportLine.new
    sr_line.status_report = StatusReport.find_by_title("Status report test")
    sr_line.milestone = Milestone.find(:first)
    sr_line.traffic_code = Code.find_by_type_name_and_name("StatusReport","Traffic")    
    sr_line.percent_complete = 50
    assert sr_line.valid?
    assert sr_line.save  
  end
    
  # Check that a duplicate status report line cannot be entered.
  def test_duplicate_status_report_line_invalid
    sr = StatusReport.new
    sr.title = 'Status report test'
    sr.parent = Project.find(:first)
    sr.role = Role.find(:first)
    sr.person = Person.find(:first)
    sr.status = Status.find_by_type_name("StatusReport")
    sr.priority_code = Code.find_by_type_name_and_name("StatusReport","Priority")
    sr.escalation = sr.parent
    sr.updated_by = sr.person
    sr.detail.period_ending_on = '2006-10-31'
    sr.detail.traffic_code = Code.find_by_type_name_and_name("StatusReport","Traffic")
    sr.detail.achievements = "test achievement text"
    sr.detail.support_required = "test support reqd text"
    assert_valid sr.detail
    assert_valid sr
    assert sr.save
    sr_line = StatusReportLine.new
    sr_line.status_report = StatusReport.find_by_title("Status report test")
    sr_line.milestone = Milestone.find_by_title("Father milestone")
    sr_line.percent_complete = 50
    sr_line.traffic_code = Code.find_by_type_name_and_name("StatusReport","Traffic")
    assert_valid sr_line
    assert sr_line.save
    sr_line1 = StatusReportLine.new
    sr_line1.status_report = StatusReport.find_by_title("Status report test")
    sr_line1.milestone = Milestone.find_by_title("Father milestone")
    sr_line1.percent_complete = 50
    sr_line1.traffic_code = Code.find_by_type_name_and_name("StatusReport","Traffic")
    assert !sr_line1.valid?
    sr_line1.milestone = Milestone.find_by_title("Father milestone on track")
    assert_valid sr_line1
    assert sr_line1.save
  end
end
