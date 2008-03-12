class StartQualityDomain < ActiveRecord::Migration
  def self.up
    create_table 'requirement_details' do |t|
      t.column :requirement_id, :integer, :null => false
      t.column :code_id_type, :integer, :null => false
      t.column :code_id_area, :integer, :null => false
      t.column :detail, :text
      t.column :person_id_sponsor, :integer
      t.column :person_id_expert, :integer
      t.column :requirement_detail_id_parent, :integer
      t.column :res_lft, :integer
      t.column :res_rgt, :integer
    end
    
    create_table 'test_condition_details' do |t|
      t.column :test_condition_id, :string, :null => false
      t.column :requirement_id, :integer
      t.column :code_id_type, :integer, :null => false
      t.column :detail, :text
      t.column :milestone_id_phase_covered, :integer, :null => false
    end
    
    create_table 'test_case_details' do |t|
      t.column :test_case_id, :integer, :null => false
      t.column :milestone_id_preparation, :integer, :null => false
      t.column :milestone_id_execution, :integer, :null => false
      t.column :preconditions, :text
      t.column :environment_requirements, :text
      t.column :data_requirements, :text
      t.column :initialisation, :text
      t.column :steps, :text
      t.column :finalisation, :text
    end
    
    # A test case has many test case runs.
    create_table 'test_case_runs' do |t|
      t.column :test_case_id, :integer, :null => false
      t.column :run_on, :date
      t.column :code_id_environment, :integer, :null => false
      t.column :person_id_run_by, :integer, :null => false
      t.column :milestone_id, :integer, :null => false
      t.column :code_id_outcome, :integer
    end
    
    create_table 'test_observation_details' do |t|
      t.column :test_observation_id, :integer, :null => false
      t.column :steps_to_reproduce, :text
      t.column :expected_results, :text
      t.column :actual_results, :text
      t.column :code_id_severity, :integer
      t.column :milestone_id_phase_detected, :integer
      t.column :milestone_id_phase_resolved, :integer
      t.column :code_id_root_cause, :integer
      t.column :milestone_id_phase_introduced, :integer
    end
  end

  def self.down
    drop_table 'requirement_details'
    drop_table 'test_condition_details'
    drop_table 'test_case_details'
    drop_table 'test_case_runs'
    drop_table 'test_observation_details'
  end
end
