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
  
  # validates_presence_of :issue_id
end
