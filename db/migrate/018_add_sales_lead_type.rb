class AddSalesLeadType < ActiveRecord::Migration

  def self.up

    create_table :sales_lead_details do |t|
      t.column :sales_lead_id, :integer, :null => false
      t.column :client, :string, :null => false
      t.column :notes, :text
      t.column :likelihood, :integer, :default => 50
      t.column :value, :integer
      t.column :code_id_service_line, :integer
    end
    add_index "sales_lead_details", ["sales_lead_id"], :name => "ak_sales_lead_details", :unique => true

  end

  def self.down
    drop_table :sales_lead_details
  end

end
