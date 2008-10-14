class TestObservationExternalRef < ActiveRecord::Migration
  def self.up
    add_column :test_observation_details, :external_reference, :string
  end

  def self.down
    remove_column :test_observation_details, :external_reference
  end
end
