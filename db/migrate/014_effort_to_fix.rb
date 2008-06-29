class EffortToFix < ActiveRecord::Migration
  def self.up
    add_column :test_observation_details, :estimated_hours_to_fix, :float
    add_column :test_observation_details, :actual_hours_to_fix, :float
  end

  def self.down
    remove_column :test_observation_details, :estimated_hours_to_fix
    remove_column :test_observation_details, :actual_hours_to_fix
  end
end
