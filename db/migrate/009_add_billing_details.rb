class AddBillingDetails < ActiveRecord::Migration
  def self.up
    add_column :person_details, :res_cc_name, :string
    add_column :person_details, :res_cc_num, :string
    add_column :person_details, :res_cc_ccv, :integer
    add_column :person_details, :res_cc_mon, :integer
    add_column :person_details, :res_cc_year, :integer
    add_column :project_details, :res_code_id_billing_plan, :integer
  end

  def self.down
    remove_column :person_details, :res_cc_name
    remove_column :person_details, :res_cc_num
    remove_column :person_details, :res_cc_ccv
    remove_column :person_details, :res_cc_mon
    remove_column :person_details, :res_cc_year
    remove_column :project_details, :res_code_id_billing_plan
  end
end
