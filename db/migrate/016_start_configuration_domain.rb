class StartConfigurationDomain < ActiveRecord::Migration
  def self.up
    create_table 'release_details' do |t|
      t.integer :release_id, :null => false
      t.text :deployment_instructions
      t.text :rollback_instructions
    end

    create_table 'component_details' do |t|
      t.column :component_id, :integer, :null => false
      t.column :component_detail_id_parent, :integer
      t.column :res_lft, :integer
      t.column :res_rgt, :integer
      t.integer :code_id_type, :null => false
    end
  end

  def self.down
    drop_table :component_details 
    drop_table :release_details
  end
end
