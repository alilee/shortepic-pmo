require File.dirname(__FILE__) + '/../test_helper'

class StatusReportTest < Test::Unit::TestCase
  fixtures :items, :status_report_details, :statuses, :codes

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
    assert !sr.detail.valid?
    sr.detail.period_ending_on = '2006-10-31'
    sr.detail.traffic_code = Code.find_by_type_name_and_name("StatusReport","Traffic")
    assert_valid sr.detail
    assert_valid sr
    assert sr.save
    sr1 = StatusReport.find_by_title('Status report test')
    assert_not_nil sr1
    sr_detail1 = StatusReportDetail.find_by_status_report_id(sr1.id)
    assert_not_nil sr_detail1
  end
  
  # Test that a invalid code cannot be added.
  def test_valid_traffic_code
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
    sr.detail.traffic_code = Code.find_by_type_name("ChangeRequest")
    assert !sr.detail.valid?
    assert_equal "is not included in the list", sr.detail.errors.on(:code_id_traffic)
    sr.detail.traffic_code = Code.find_by_type_name_and_name("StatusReport","Priority")
    assert !sr.detail.valid?
    assert_equal "is not included in the list", sr.detail.errors.on(:code_id_traffic)
    sr.detail.traffic_code = Code.find_by_type_name_and_name("StatusReport","Traffic")
    assert_valid sr.detail
    assert_valid sr
    assert sr.save
  end
end