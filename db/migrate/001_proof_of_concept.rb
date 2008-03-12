class ProofOfConcept < ActiveRecord::Migration

  def self.up

    create_table "action_item_details", :force => true do |t|
      t.column "action_item_id", :integer, :null => false
      t.column "code_id_environment", :integer, :null => false
      t.column "starting_at", :datetime
      t.column "start_signal", :string
      t.column "target_complete_at", :datetime
      t.column "forecast_complete_at", :datetime
      t.column "update_interval", :string      
      t.column "contingency_plan", :text
      t.column "use_contingency_at", :datetime
    end

    add_index "action_item_details", ["action_item_id"], :name => "ak_action_item_details", :unique => true

    create_table "associations", :force => true do |t|
      t.column "item_id_from", :integer, :null => false
      t.column "item_id_to", :integer, :null => false
    end

    add_index "associations", ["item_id_from", "item_id_to"], :name => "ak_associations", :unique => true
    add_index "associations", ["item_id_from", "item_id_to"], :name => "index_associations_to_from"

    create_table "attachment_contents", :force => true do |t|
      t.column "data", :binary
      t.column "attachment_id", :integer, :null => false
    end

    create_table "attachments", :force => true do |t|
      t.column "item_id", :integer, :null => false
      t.column "filename", :string, :null => false
      t.column "version", :string, :null => false
      t.column "size", :integer, :null => false
      t.column "created_at", :datetime, :null => false
      t.column "person_id", :integer, :null => false
      t.column "mime_type", :string, :null => false
    end

    add_index "attachments", ["item_id", "filename", "version"], :name => "ak_attachments", :unique => true

    create_table "change_request_details", :force => true do |t|
      t.column "change_request_id", :integer, :null => false
      t.column "background", :text
      t.column "res_approved_on", :date
    end

    add_index "change_request_details", ["change_request_id"], :name => "ak_change_request_details", :unique => true

    create_table "codes", :force => true do |t|
      t.column "type_name", :string, :null => false
      t.column "name", :string, :null => false
      t.column "value", :string, :null => false
      t.column "enabled", :boolean, :default => true, :null => false
    end

    add_index "codes", ["type_name", "name", "value"], :name => "ak_codes", :unique => true
    add_index "codes", ["enabled", "type_name", "name"], :name => "index_enabled_codes"

    create_table "comments", :force => true do |t|
      t.column "item_id", :integer, :null => false
      t.column "body", :text, :null => false
      t.column "created_at", :datetime, :null => false
      t.column "person_id", :integer, :null => false
    end

    add_index "comments", ["item_id"], :name => "index_comment_item_ids"

    create_table "cr_date_lines", :force => true do |t|
      t.column "change_request_id", :integer, :null => false
      t.column "milestone_id", :integer, :null => false
      t.column "start_on", :date, :null => false
      t.column "end_on", :date, :null => false
    end

    add_index "cr_date_lines", ["change_request_id", "milestone_id"], :name => "ak_cr_date_lines", :unique => true
    add_index "cr_date_lines", ["milestone_id"], :name => "index_cr_date_milestone_id"

    create_table "cr_effort_lines", :force => true do |t|
      t.column "change_request_id", :integer, :null => false
      t.column "milestone_id", :integer, :null => false
      t.column "role_id", :integer, :null => false
      t.column "hours", :integer, :null => false
      t.column "effort_budget", :integer, :null => false
    end

    add_index "cr_effort_lines", ["change_request_id", "milestone_id", "role_id"], :name => "ak_cr_effort_lines", :unique => true
    add_index "cr_effort_lines", ["milestone_id"], :name => "index_cr_effort_milestone_id"

    create_table "cr_expense_lines", :force => true do |t|
      t.column "change_request_id", :integer, :null => false
      t.column "milestone_id", :integer, :null => false
      t.column "role_id", :integer, :null => false
      t.column "code_id_purpose", :integer, :null => false
      t.column "expense_budget", :integer, :null => false
    end

    add_index "cr_expense_lines", ["change_request_id", "milestone_id", "role_id"], :name => "ak_cr_expense_lines", :unique => true
    add_index "cr_expense_lines", ["milestone_id"], :name => "index_cr_expense_milestone_id"

    create_table "expense_claim_details", :force => true do |t|
      t.column "expense_claim_id", :integer, :null => false
      t.column "period_ending_on", :date, :null => false
    end

    add_index "expense_claim_details", ["expense_claim_id"], :name => "ak_expense_details", :unique => true

    create_table "expense_claim_lines", :force => true do |t|
      t.column "expense_claim_id", :integer, :null => false
      t.column "milestone_id", :integer, :null => false
      t.column "role_id", :integer, :null => false
      t.column "code_id_purpose", :integer, :null => false
      t.column "amount_spent", :integer, :null => false
      t.column "amount_estimated_to_complete", :integer
    end

    add_index "expense_claim_lines", ["expense_claim_id", "milestone_id", "role_id", "code_id_purpose"], :name => "ak_expense_claim_lines", :unique => true
    add_index "expense_claim_lines", ["milestone_id"], :name => "index_expense_claim_lines_milestone"

    create_table "issue_details", :force => true do |t|
      t.column "issue_id", :integer, :null => false
      t.column "background", :text
      t.column "alternatives", :text
      t.column "recommendation", :text
    end

    add_index "issue_details", ["issue_id"], :name => "ak_issue_details", :unique => true

    create_table "items", :force => true do |t|
      t.column "type", :string, :null => false
      t.column "title", :string, :null => false
      t.column "project_id", :integer
      t.column "role_id", :integer, :null => false
      t.column "person_id", :integer, :null => false
      t.column "status_id", :integer, :null => false
      t.column "code_id_priority", :integer, :null => false
      t.column "project_id_escalation", :integer
      t.column "description", :text
      t.column "due_on", :date
      t.column "lft", :integer
      t.column "rgt", :integer
      t.column "updated_at", :datetime, :null => false
      t.column "person_id_updated_by", :integer, :null => false
    end
    Item.create_versioned_table :force => true

    add_index "items", ["project_id", "title"], :name => "ak_item_project_id_title", :unique => true
    add_index "items", ["type", "project_id"], :name => "index_type_project_id"

    create_table "milestone_details", :force => true do |t|
      t.column "milestone_id", :integer, :null => false
      t.column "deadline_on", :date 
    end

    add_index "milestone_details", ["milestone_id"], :name => "ak_milestone_details", :unique => true

    create_table "person_contacts", :force => true do |t|
      t.column "person_id", :integer, :null => false
      t.column "code_id_contact", :integer, :null => false
      t.column "address", :string, :null => false
    end

    add_index "person_contacts", ["person_id", "code_id_contact", "address"], :name => "ak_person_contacts", :unique => true

    create_table "person_details", :force => true do |t|
      t.column "person_id", :integer, :null => false
      t.column "email", :string, :null => false
      t.column "code_id_timezone", :integer, :null => false
      t.column "res_password_hash", :string, :null => false
      t.column "res_password_salt", :string, :null => false
      t.column "reset_next_login", :boolean, :default => true
    end

    add_index "person_details", ["person_id"], :name => "ak_person_details", :unique => true

    create_table "project_details", :force => true do |t|
      t.column "project_id", :integer, :null => false
      t.column "discount_rate", :float
    end

    add_index "project_details", ["project_id"], :name => "ak_project_details", :unique => true

    # TODO: A - Update risk fields for contingency model
    create_table "risk_details", :force => true do |t|
      t.column "risk_id", :integer, :null => false
      t.column "code_id_pre_likelihood", :integer
      t.column "code_id_pre_impact", :integer
      t.column "code_id_strategy", :integer
      t.column "strategy", :text
      t.column "code_id_post_likelihood", :integer
      t.column "code_id_post_impact", :integer
    end

    add_index "risk_details", ["risk_id"], :name => "ak_risk_details", :unique => true

    create_table "role_details", :force => true do |t|
      t.column "role_id", :integer, :null => false
      t.column "skills", :text
      t.column "experience", :text
      t.column "accountabilities", :text
      t.column "responsibilities", :text
      t.column "code_id_security_profile", :integer, :null => false
    end

    add_index "role_details", ["role_id"], :name => "ak_role_details", :unique => true

    create_table "role_placements", :force => true do |t|
      t.column "person_id", :integer, :null => false
      t.column "role_id", :integer, :null => false
      t.column "start_on", :date, :null => false
      t.column "end_on", :date, :null => false
      t.column "committed_hours", :integer, :null => false
      t.column "normal_hourly_rate", :integer, :null => false
      t.column "overtime_hourly_rate", :integer
    end

    add_index "role_placements", ["person_id", "role_id", "start_on"], :name => "ak_role_placements", :unique => true

    create_table "role_security_profiles", :force => true do |t|
      t.column "code_id_security_profile", :integer, :null => false
      t.column "controller_name", :string
      t.column "action", :string
    end

    add_index "role_security_profiles", ["code_id_security_profile", "controller_name", "action"], :name => "ak_role_security_profiles", :unique => true

    create_table "sessions", :force => true do |t|
      t.column "session_id", :string
      t.column "data", :text
      t.column "updated_at", :datetime
    end

    add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

    create_table "signatures", :force => true do |t|
      t.column "item_id", :integer, :null => false
      t.column "person_id", :integer, :null => false
      t.column "status_id", :integer, :null => false
      t.column "signed_at", :datetime
    end

    add_index "signatures", ["item_id", "person_id", "status_id"], :name => "ak_signatures", :unique => true
    add_index "signatures", ["person_id"], :name => "index_signature_person_ids"

    create_table "status_report_details", :force => true do |t|
      t.column "status_report_id", :integer, :null => false
      t.column "period_ending_on", :date, :null => false
      t.column "code_id_traffic", :integer, :null => false
      t.column "achievements", :text
      t.column "support_required", :text
    end

    add_index "status_report_details", ["status_report_id"], :name => "ak_status_report_details", :unique => true

    create_table "status_report_lines", :force => true do |t|
      t.column "status_report_id", :integer, :null => false
      t.column "milestone_id", :integer, :null => false
      t.column "code_id_traffic", :integer, :null => false
      t.column "percent_complete", :integer, :null => false
      t.column "forecast_complete_on", :date
    end

    add_index "status_report_lines", ["status_report_id", "milestone_id"], :name => "ak_statusreport_lines", :unique => true
    add_index "status_report_lines", ["milestone_id"], :name => "index_statusreport_lines_milestone"

    create_table "status_transitions", :force => true do |t|
      t.column "type_name", :string, :null => false
      t.column "value_from", :string, :null => false
      t.column "value_to", :string, :null => false
      t.column "credential_required", :string
    end

    add_index "status_transitions", ["type_name", "value_from", "value_to", "credential_required"], :name => "ak_status_transitions", :unique => true

    create_table "statuses", :force => true do |t|
      t.column "type_name", :string, :null => false
      t.column "value", :string, :null => false
      t.column "generic_stage", :string, :null => false
      t.column "enabled", :boolean, :default => true, :null => false
    end

    add_index "statuses", ["type_name", "value"], :name => "ak_statuses", :unique => true
    add_index "statuses", ["enabled", "type_name", "generic_stage"], :name => "index_statuses_generic"

    create_table "subscriptions", :force => true do |t|
      t.column "item_id", :integer, :null => false
      t.column "person_id", :integer, :null => false
      t.column "email_notification", :boolean, :default => true
      t.column "sms_notification", :boolean, :default => false
    end

    add_index "subscriptions", ["item_id", "person_id"], :name => "ak_subscriptions", :unique => true

    create_table "system_settings", :force => true do |t|
      t.column "name", :string, :null => false
      t.column "value", :string
      t.column "category", :string, :null => false
      t.column "explanation", :text
      t.column "example", :string
    end

    add_index "system_settings", ["name", "category"], :name => "ak_system_settings_category_name", :unique => true

    create_table "timesheet_details", :force => true do |t|
      t.column "timesheet_id", :integer, :null => false
      t.column "person_id_worker", :integer, :null => false
      t.column "period_ending_on", :date, :null => false
      t.column "res_approved_on", :date
    end

    add_index "timesheet_details", ["timesheet_id"], :name => "ak_timesheet_details", :unique => true

    create_table "timesheet_lines", :force => true do |t|
      t.column "timesheet_id", :integer, :null => false
      t.column "milestone_id", :integer, :null => false
      t.column "role_id", :integer, :null => false
      t.column "worked_on", :date, :null => false
      t.column "normal_hours", :integer, :null => false
      t.column "overtime_hours", :integer
      t.column "uncharged_hours", :integer
      t.column "hours_estimated_to_complete", :integer
    end

    add_index "timesheet_lines", ["timesheet_id", "milestone_id", "role_id", "worked_on"], :name => "ak_timesheet_lines", :unique => true
    add_index "timesheet_lines", ["milestone_id"], :name => "index_timesheet_lines_milestone_id"

  end

  def self.down
    drop_table "action_item_details"
    drop_table "associations"
    drop_table "attachment_contents"
    drop_table "attachments"
    drop_table "change_request_details"
    drop_table "codes"
    drop_table "comments"
    drop_table "cr_date_lines"
    drop_table "cr_effort_lines"
    drop_table "cr_expense_lines"
    drop_table "expense_claim_details"
    drop_table "expense_claim_lines"
    drop_table "issue_details"
    drop_table "items"
    Item.drop_versioned_table
    drop_table "milestone_details"
    drop_table "person_contacts"
    drop_table "person_details"
    drop_table "project_details"
    drop_table "risk_details"
    drop_table "role_details"
    drop_table "role_placements"
    drop_table "sessions"
    drop_table "signatures"
    drop_table "status_report_details"
    drop_table "status_report_lines"
    drop_table "status_transitions"
    drop_table "statuses"
    drop_table "subscriptions"
    drop_table "system_settings"
    drop_table "timesheet_details"
    drop_table "timesheet_lines"
  end
  
end
