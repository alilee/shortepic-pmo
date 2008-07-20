# == Schema Information
# Schema version: 16
#
# Table name: timesheet_details
#
#  id               :integer       not null, primary key
#  timesheet_id     :integer       not null
#  person_id_worker :integer       not null
#  period_ending_on :date          not null
#  res_approved_on  :date          
#

# TODO: B - validate that timesheets do not overlap.
class TimesheetDetail < ActiveRecord::Base
  include ItemDetail

	belongs_to :worker, :class_name => 'Person', :foreign_key => 'person_id_worker'
	belongs_to :timesheet
	
	# validates_presence_of :timesheet_id
	validates_presence_of :period_ending_on, :person_id_worker
	
	attr_protected :res_approved_on
end
