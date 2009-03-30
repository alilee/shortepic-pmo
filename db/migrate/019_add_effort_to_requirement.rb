class AddEffortToRequirement < ActiveRecord::Migration
  def self.up
    add_column :requirement_details, :effort, :integer
  end

  def self.down
    remove_column :requirement_details, :effort
  end
end
