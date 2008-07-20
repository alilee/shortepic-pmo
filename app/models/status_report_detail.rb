# == Schema Information
# Schema version: 16
#
# Table name: status_report_details
#
#  id               :integer       not null, primary key
#  status_report_id :integer       not null
#  period_ending_on :date          not null
#  code_id_traffic  :integer       not null
#  achievements     :text          
#  support_required :text          
#

class StatusReportDetail < ActiveRecord::Base
  include ItemDetail

  belongs_to :status_report
  belongs_to :traffic_code, :class_name => 'Code', :foreign_key => 'code_id_traffic'
 
  # validates_presence_of :status_report_id
  validates_presence_of :code_id_traffic, :period_ending_on
  validate :validate_traffic_code
  
  protected
  
  def validate_traffic_code
    unless traffic_code && traffic_code.name == 'Traffic' && traffic_code.type_name == 'StatusReport'
      errors.add(:code_id_traffic, 'is not included in the list')
    end
  end
  
end
