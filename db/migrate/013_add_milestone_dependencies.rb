class AddMilestoneDependencies < ActiveRecord::Migration
  def self.up
    create_table :milestone_dependencies do |t|
      t.column :milestone_id, :integer, :null => false
      t.column :milestone_id_predecessor, :integer, :null => false
      t.column :code_id_dependency_type, :integer, :null => false
      t.column :is_critical, :boolean
    end
    add_index :milestone_dependencies, [:milestone_id, :milestone_id_predecessor], :name => :ak_milestone_dependencies, :unique => true
  end

  def self.down
    drop_table :milestone_dependencies
  end
end
