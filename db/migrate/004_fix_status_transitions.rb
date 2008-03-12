# replaces the credential_required field with a code_id_security_profile field. Drops and
# recreates the index because it is part of the alternate key.
class FixStatusTransitions < ActiveRecord::Migration
  def self.up
    remove_index :status_transitions, :name => :ak_status_transitions
    
    rename_column :status_transitions, :credential_required, :code_id_security_profile
    change_column :status_transitions, :code_id_security_profile, :integer, :null => false

    rename_column :status_transitions, :value_from, :status_id_from
    change_column :status_transitions, :status_id_from, :integer, :null => false

    rename_column :status_transitions, :value_to, :status_id_to
    change_column :status_transitions, :status_id_to, :integer, :null => false

    add_index "status_transitions", ["type_name", "status_id_from", "status_id_to", "code_id_security_profile"], :name => "ak_status_transitions", :unique => true
  end

  def self.down
    remove_index :status_transitions, :name => :ak_status_transitions

    rename_column :status_transitions, :status_id_from, :value_from
    change_column :status_transitions, :value_from, :string, :null => false

    rename_column :status_transitions, :status_id_to, :value_to
    change_column :status_transitions, :value_to, :string, :null => false

    change_column :status_transitions, :code_id_security_profile, :string, :null => false
    execute('ALTER TABLE status_transitions ALTER code_id_security_profile DROP NOT NULL')

    rename_column :status_transitions, :code_id_security_profile, :credential_required
    
    add_index "status_transitions", ["type_name", "value_from", "value_to", "credential_required"], :name => "ak_status_transitions", :unique => true
  end
end
