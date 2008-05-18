# == Schema Information
# Schema version: 12
#
# Table name: test_observation_details
#
#  id                            :integer       not null, primary key
#  test_observation_id           :integer       not null
#  steps_to_reproduce            :text          
#  expected_results              :text          
#  actual_results                :text          
#  code_id_severity              :integer       
#  milestone_id_phase_detected   :integer       
#  milestone_id_phase_resolved   :integer       
#  code_id_root_cause            :integer       
#  milestone_id_phase_introduced :integer       
#

class TestObservationDetail < ActiveRecord::Base
  include ItemDetail

  belongs_to :test_observation
  belongs_to :phase_detected_milestone, :class_name => 'Milestone', :foreign_key => 'milestone_id_phase_detected'
  belongs_to :phase_resolved_milestone, :class_name => 'Milestone', :foreign_key => 'milestone_id_phase_resolved'
  belongs_to :phase_introduced_milestone, :class_name => 'Milestone', :foreign_key => 'milestone_id_phase_introduced'
  belongs_to :root_cause_code, :class_name => 'Code', :foreign_key => 'code_id_root_cause'
  belongs_to :severity_code, :class_name => 'Code', :foreign_key => 'code_id_severity'
  
  # validates_presence_of :issue_id
end
