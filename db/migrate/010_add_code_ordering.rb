class AddCodeOrdering < ActiveRecord::Migration
  def self.up
    add_column :codes, :sequence, :integer, :default => 50
    execute 'UPDATE codes SET sequence = 50 WHERE sequence IS NULL'
    execute 'ALTER TABLE codes ALTER sequence SET NOT NULL'
  end

  def self.down
    remove_column :codes, :sequence
  end
end
