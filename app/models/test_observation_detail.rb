# == Schema Information
# Schema version: 16
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
#  estimated_hours_to_fix        :float         
#  actual_hours_to_fix           :float         
#  code_id_functional_area       :integer       
#

class TestObservationDetail < ActiveRecord::Base
  include ItemDetail

  belongs_to :test_observation
  belongs_to :phase_detected_milestone, :class_name => 'Milestone', :foreign_key => 'milestone_id_phase_detected'
  belongs_to :phase_resolved_milestone, :class_name => 'Milestone', :foreign_key => 'milestone_id_phase_resolved'
  belongs_to :phase_introduced_milestone, :class_name => 'Milestone', :foreign_key => 'milestone_id_phase_introduced'
  belongs_to :root_cause_code, :class_name => 'Code', :foreign_key => 'code_id_root_cause'
  belongs_to :severity_code, :class_name => 'Code', :foreign_key => 'code_id_severity'
  belongs_to :functional_area_code, :class_name => 'Code', :foreign_key => 'code_id_functional_area'
  
  # Return a string in CSV format containing the details of the object
  def to_csv
    a = [ steps_to_reproduce, expected_results, actual_results, severity_code, phase_detected_milestone.title, phase_resolved_milestone.title, root_cause_code, phase_resolved_milestone.title, estimated_hours_to_fix, actual_hours_to_fix, functional_area_code ]
    CSV.generate_line(a)
  end
  
  def self.to_csv_header
    a = [ 'steps_to_reproduce', 'expected_results', 'actual_results', 'severity_code', 'phase_detected_milestone', 'phase_resolved_milestone', 'root_cause_code', 'phase_resolved_milestone', 'estimated_hours_to_fix', 'actual_hours_to_fix', 'functional_area_code' ]
    CSV.generate_line(a)
  end
  
end
