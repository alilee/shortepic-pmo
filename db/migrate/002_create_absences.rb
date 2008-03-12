class CreateAbsences < ActiveRecord::Migration
  def self.up
    create_table :absence_details do |t|
      t.column "absence_id", :integer, :null => false
      t.column "person_id", :integer, :null => false
      t.column "away_on", :date, :null => false
      t.column "back_on", :date, :null => false
      t.column "code_id_availability", :integer, :null => false
    end
  end

  def self.down
    drop_table :absence_details
  end
end
