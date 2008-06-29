class FunctionalAreaIntoDefect < ActiveRecord::Migration
  def self.up
    add_column :test_observation_details, :code_id_functional_area, :integer
  end

  def self.down
    remove_column :test_observation_details, :code_id_functional_area
  end
end
