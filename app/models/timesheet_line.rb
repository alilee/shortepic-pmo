# == Schema Information
# Schema version: 12
#
# Table name: timesheet_lines
#
#  id                          :integer       not null, primary key
#  timesheet_id                :integer       not null
#  milestone_id                :integer       not null
#  role_id                     :integer       not null
#  worked_on                   :date          not null
#  normal_hours                :integer       not null
#  overtime_hours              :integer       
#  uncharged_hours             :integer       
#  hours_estimated_to_complete :integer       
#

class TimesheetLine < ActiveRecord::Base
  belongs_to :timesheet, :include => :detail
  belongs_to :milestone
  belongs_to :role
  # TODO: C - Should we preload detail and worker record?
  #belongs_to :timesheet_detail, :include => :worker
  
  validates_presence_of :timesheet_id, :milestone_id, :role_id, :worked_on, :normal_hours
  validates_uniqueness_of :worked_on, :scope => [:role_id, :milestone_id, :timesheet_id]
  # TODO: C - Should hours be decimals?
  validates_numericality_of :normal_hours
  validates_numericality_of :overtime_hours, :allow_nil => true
  validates_numericality_of :uncharged_hours, :allow_nil => true
  validates_inclusion_of :normal_hours, :in => 0..168, :message => "should be between 0 and 168"
  validates_inclusion_of :overtime_hours, :allow_nil => true, :in => 0..168, :message => "should be between 0 and 168"
  validates_inclusion_of :uncharged_hours, :allow_nil => true, :in => 0..168, :message => "should be between 0 and 168"
    
end
