# == Schema Information
# Schema version: 12
#
# Table name: cr_effort_lines
#
#  id                :integer       not null, primary key
#  change_request_id :integer       not null
#  milestone_id      :integer       not null
#  role_id           :integer       not null
#  hours             :integer       not null
#  effort_budget     :integer       not null
#

class CrEffortLine < ActiveRecord::Base
  belongs_to :change_request
  belongs_to :milestone
  belongs_to :role
  
  validates_presence_of :change_request_id, :milestone_id, :role_id, :hours, :effort_budget
  validates_uniqueness_of :role_id, :scope => [:change_request_id, :milestone_id]    
  validates_numericality_of :hours, :effort_budget
  validates_inclusion_of :hours, :in => 0..999999, :message => 'should be positive'
  validates_inclusion_of :effort_budget, :in => 0..999999999, :message => 'should be positive'
  
end
