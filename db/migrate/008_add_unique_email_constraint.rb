class AddUniqueEmailConstraint < ActiveRecord::Migration
  def self.up
    add_index :person_details, :email, :unique => true, :name => 'ak_person_email'
  end

  def self.down
    remove_index :person_details, :name => 'ak_person_email'
  end
end
