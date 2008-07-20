# == Schema Information
# Schema version: 16
#
# Table name: status_report_lines
#
#  id                   :integer       not null, primary key
#  status_report_id     :integer       not null
#  milestone_id         :integer       not null
#  code_id_traffic      :integer       not null
#  percent_complete     :integer       not null
#  forecast_complete_on :date          
#

# A status report line represents how the an individual
# milestone is tracking at the time that the parent status
# report was issued.
class StatusReportLine < ActiveRecord::Base
  
  belongs_to :status_report
  belongs_to :milestone
  belongs_to :traffic_code, :class_name => 'Code', :foreign_key => 'code_id_traffic'
  
  validates_presence_of :status_report_id, :milestone_id, :code_id_traffic, :percent_complete
  validates_numericality_of :percent_complete, :only_integer => true
  validates_uniqueness_of :milestone_id, :scope => 'status_report_id'
  validates_inclusion_of :percent_complete, :in => 0..100, :message => 'should be between 0 and 100'

  def last_forecast_complete_on
    result = StatusReportLine.find_by_milestone_id(milestone_id, 
      :include => {:status_report => :status}, 
      :conditions => ['generic_stage = ? and status_report_lines.id < ?', Status::COMPLETE, self.id],
      :order => 'status_report_lines.id DESC')
    result ? result.forecast_complete_on : nil
  end
  
  def baseline_end_on
    result = milestone.baseline_ends_on
  end  
end
