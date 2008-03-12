class AddMeetingType < ActiveRecord::Migration
  def self.up
    create_table :meeting_details do |t|
      t.column :meeting_id, :integer, :null => false
      t.column :start_at, :datetime
      t.column :finish_at, :datetime
      t.column :location, :string
      t.column :resolved, :text
    end
    add_index "meeting_details", ["meeting_id"], :name => "ak_meeting_details", :unique => true
    
    create_table :meeting_attendees do |t|
      t.column :meeting_id, :integer, :null => false
      t.column :person_id, :integer, :null => false
    end
    add_index "meeting_attendees", ["meeting_id", "person_id"], :name => "ak_meeting_attendees", :unique => true
  end

  def self.down
    drop_table :meeting_attendees
    drop_table :meeting_details
  end
end
