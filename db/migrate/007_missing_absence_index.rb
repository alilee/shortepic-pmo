class MissingAbsenceIndex < ActiveRecord::Migration
  def self.up
    add_index "absence_details", "absence_id", :name => "ak_absence_details", :unique => true
  end

  def self.down
    remove_index :absence_details, :name => 'ak_absence_details'
  end
end
