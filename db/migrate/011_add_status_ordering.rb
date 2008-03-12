class AddStatusOrdering < ActiveRecord::Migration
  def self.up
    add_column :statuses, :sequence, :integer, :default => 50
    
    Status.find(:all).each do |s|
      s.sequence = Status::VALID_GENERIC.index(s.generic_stage)*10
      s.save!
    end
    
    execute 'ALTER TABLE statuses ALTER sequence SET NOT NULL'
  end

  def self.down
    remove_column :statuses, :sequence
  end
end
