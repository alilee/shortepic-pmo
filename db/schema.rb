# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 18) do

  create_table "absence_details", :force => true do |t|
    t.integer "absence_id",           :null => false
    t.integer "person_id",            :null => false
    t.date    "away_on",              :null => false
    t.date    "back_on",              :null => false
    t.integer "code_id_availability", :null => false
  end

  add_index "absence_details", ["absence_id"], :name => "ak_absence_details", :unique => true

  create_table "action_item_details", :force => true do |t|
    t.integer  "action_item_id",       :null => false
    t.integer  "code_id_environment",  :null => false
    t.datetime "starting_at"
    t.string   "start_signal"
    t.datetime "target_complete_at"
    t.datetime "forecast_complete_at"
    t.string   "update_interval"
    t.text     "contingency_plan"
    t.datetime "use_contingency_at"
  end

  add_index "action_item_details", ["action_item_id"], :name => "ak_action_item_details", :unique => true

  create_table "associations", :force => true do |t|
    t.integer "item_id_from", :null => false
    t.integer "item_id_to",   :null => false
  end

  add_index "associations", ["item_id_from", "item_id_to"], :name => "ak_associations", :unique => true
  add_index "associations", ["item_id_from", "item_id_to"], :name => "index_associations_to_from"

  create_table "attachment_contents", :force => true do |t|
    t.binary  "data"
    t.integer "attachment_id", :null => false
  end

  create_table "attachments", :force => true do |t|
    t.integer  "item_id",    :null => false
    t.string   "filename",   :null => false
    t.string   "version",    :null => false
    t.integer  "size",       :null => false
    t.datetime "created_at", :null => false
    t.integer  "person_id",  :null => false
    t.string   "mime_type",  :null => false
  end

  add_index "attachments", ["item_id", "filename", "version"], :name => "ak_attachments", :unique => true

  create_table "change_request_details", :force => true do |t|
    t.integer "change_request_id", :null => false
    t.text    "background"
    t.date    "res_approved_on"
  end

  add_index "change_request_details", ["change_request_id"], :name => "ak_change_request_details", :unique => true

  create_table "codes", :force => true do |t|
    t.string  "type_name",                   :null => false
    t.string  "name",                        :null => false
    t.string  "value",                       :null => false
    t.boolean "enabled",   :default => true, :null => false
    t.integer "sequence",  :default => 50,   :null => false
  end

  add_index "codes", ["type_name", "name", "value"], :name => "ak_codes", :unique => true
  add_index "codes", ["type_name", "name", "enabled"], :name => "index_enabled_codes"

  create_table "comments", :force => true do |t|
    t.integer  "item_id",    :null => false
    t.text     "body",       :null => false
    t.datetime "created_at", :null => false
    t.integer  "person_id",  :null => false
  end

  add_index "comments", ["item_id"], :name => "index_comment_item_ids"

  create_table "component_details", :force => true do |t|
    t.integer "component_id",               :null => false
    t.integer "component_detail_id_parent"
    t.integer "res_lft"
    t.integer "res_rgt"
    t.integer "code_id_type",               :null => false
  end

  create_table "cr_date_lines", :force => true do |t|
    t.integer "change_request_id", :null => false
    t.integer "milestone_id",      :null => false
    t.date    "start_on",          :null => false
    t.date    "end_on",            :null => false
  end

  add_index "cr_date_lines", ["change_request_id", "milestone_id"], :name => "ak_cr_date_lines", :unique => true
  add_index "cr_date_lines", ["milestone_id"], :name => "index_cr_date_milestone_id"

  create_table "cr_effort_lines", :force => true do |t|
    t.integer "change_request_id", :null => false
    t.integer "milestone_id",      :null => false
    t.integer "role_id",           :null => false
    t.integer "hours",             :null => false
    t.integer "effort_budget",     :null => false
  end

  add_index "cr_effort_lines", ["change_request_id", "milestone_id", "role_id"], :name => "ak_cr_effort_lines", :unique => true
  add_index "cr_effort_lines", ["milestone_id"], :name => "index_cr_effort_milestone_id"

  create_table "cr_expense_lines", :force => true do |t|
    t.integer "change_request_id", :null => false
    t.integer "milestone_id",      :null => false
    t.integer "role_id",           :null => false
    t.integer "code_id_purpose",   :null => false
    t.integer "expense_budget",    :null => false
  end

  add_index "cr_expense_lines", ["change_request_id", "milestone_id", "role_id"], :name => "ak_cr_expense_lines", :unique => true
  add_index "cr_expense_lines", ["milestone_id"], :name => "index_cr_expense_milestone_id"

  create_table "expense_claim_details", :force => true do |t|
    t.integer "expense_claim_id", :null => false
    t.date    "period_ending_on", :null => false
  end

  add_index "expense_claim_details", ["expense_claim_id"], :name => "ak_expense_details", :unique => true

  create_table "expense_claim_lines", :force => true do |t|
    t.integer "expense_claim_id",             :null => false
    t.integer "milestone_id",                 :null => false
    t.integer "role_id",                      :null => false
    t.integer "code_id_purpose",              :null => false
    t.integer "amount_spent",                 :null => false
    t.integer "amount_estimated_to_complete"
  end

  add_index "expense_claim_lines", ["expense_claim_id", "milestone_id", "role_id", "code_id_purpose"], :name => "ak_expense_claim_lines", :unique => true
  add_index "expense_claim_lines", ["milestone_id"], :name => "index_expense_claim_lines_milestone"

  create_table "issue_details", :force => true do |t|
    t.integer "issue_id",       :null => false
    t.text    "background"
    t.text    "alternatives"
    t.text    "recommendation"
  end

  add_index "issue_details", ["issue_id"], :name => "ak_issue_details", :unique => true

  create_table "item_versions", :force => true do |t|
    t.integer  "item_id"
    t.integer  "version"
    t.string   "title"
    t.integer  "project_id"
    t.integer  "role_id"
    t.integer  "person_id"
    t.integer  "status_id"
    t.integer  "code_id_priority"
    t.integer  "project_id_escalation"
    t.text     "description"
    t.date     "due_on"
    t.datetime "updated_at"
    t.integer  "person_id_updated_by"
    t.string   "versioned_type"
  end

  create_table "items", :force => true do |t|
    t.string   "type",                                 :null => false
    t.string   "title",                                :null => false
    t.integer  "project_id"
    t.integer  "role_id",                              :null => false
    t.integer  "person_id",                            :null => false
    t.integer  "status_id",                            :null => false
    t.integer  "code_id_priority",                     :null => false
    t.integer  "project_id_escalation"
    t.text     "description"
    t.date     "due_on"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "updated_at",                           :null => false
    t.integer  "person_id_updated_by",                 :null => false
    t.integer  "version"
    t.string   "res_idx_fti",           :limit => nil
  end

  add_index "items", ["title", "project_id"], :name => "ak_item_project_id_title", :unique => true
  add_index "items", ["res_idx_fti"], :name => "index_fti"
  add_index "items", ["type", "project_id"], :name => "index_type_project_id"

  create_table "meeting_attendees", :force => true do |t|
    t.integer "meeting_id", :null => false
    t.integer "person_id",  :null => false
  end

  add_index "meeting_attendees", ["meeting_id", "person_id"], :name => "ak_meeting_attendees", :unique => true

  create_table "meeting_details", :force => true do |t|
    t.integer  "meeting_id", :null => false
    t.datetime "start_at"
    t.datetime "finish_at"
    t.string   "location"
    t.text     "resolved"
  end

  add_index "meeting_details", ["meeting_id"], :name => "ak_meeting_details", :unique => true

  create_table "milestone_dependencies", :force => true do |t|
    t.integer "milestone_id",             :null => false
    t.integer "milestone_id_predecessor", :null => false
    t.integer "code_id_dependency_type",  :null => false
    t.boolean "is_critical"
  end

  add_index "milestone_dependencies", ["milestone_id", "milestone_id_predecessor"], :name => "ak_milestone_dependencies", :unique => true

  create_table "milestone_details", :force => true do |t|
    t.integer "milestone_id", :null => false
    t.date    "deadline_on"
  end

  add_index "milestone_details", ["milestone_id"], :name => "ak_milestone_details", :unique => true

  create_table "person_contacts", :force => true do |t|
    t.integer "person_id",       :null => false
    t.integer "code_id_contact", :null => false
    t.string  "address",         :null => false
  end

  add_index "person_contacts", ["person_id", "code_id_contact", "address"], :name => "ak_person_contacts", :unique => true

  create_table "person_details", :force => true do |t|
    t.integer "person_id",                           :null => false
    t.string  "email",                               :null => false
    t.integer "code_id_timezone",                    :null => false
    t.string  "res_password_hash",                   :null => false
    t.string  "res_password_salt",                   :null => false
    t.boolean "reset_next_login",  :default => true
    t.string  "res_cc_name"
    t.string  "res_cc_num"
    t.integer "res_cc_ccv"
    t.integer "res_cc_mon"
    t.integer "res_cc_year"
  end

  add_index "person_details", ["person_id"], :name => "ak_person_details", :unique => true
  add_index "person_details", ["email"], :name => "ak_person_email", :unique => true

  create_table "project_details", :force => true do |t|
    t.integer "project_id",               :null => false
    t.float   "discount_rate"
    t.integer "status_report_interval"
    t.integer "res_code_id_billing_plan"
  end

  add_index "project_details", ["project_id"], :name => "ak_project_details", :unique => true

  create_table "release_details", :force => true do |t|
    t.integer "release_id",              :null => false
    t.text    "deployment_instructions"
    t.text    "rollback_instructions"
  end

  create_table "requirement_details", :force => true do |t|
    t.integer "requirement_id",               :null => false
    t.integer "code_id_type",                 :null => false
    t.integer "code_id_area",                 :null => false
    t.text    "detail"
    t.integer "person_id_sponsor"
    t.integer "person_id_expert"
    t.integer "requirement_detail_id_parent"
    t.integer "res_lft"
    t.integer "res_rgt"
  end

  create_table "risk_details", :force => true do |t|
    t.integer "risk_id",                 :null => false
    t.integer "code_id_pre_likelihood"
    t.integer "code_id_pre_impact"
    t.integer "code_id_strategy"
    t.text    "strategy"
    t.integer "code_id_post_likelihood"
    t.integer "code_id_post_impact"
  end

  add_index "risk_details", ["risk_id"], :name => "ak_risk_details", :unique => true

  create_table "role_details", :force => true do |t|
    t.integer "role_id",                  :null => false
    t.text    "skills"
    t.text    "experience"
    t.text    "accountabilities"
    t.text    "responsibilities"
    t.integer "code_id_security_profile", :null => false
  end

  add_index "role_details", ["role_id"], :name => "ak_role_details", :unique => true

  create_table "role_placements", :force => true do |t|
    t.integer "person_id",            :null => false
    t.integer "role_id",              :null => false
    t.date    "start_on",             :null => false
    t.date    "end_on",               :null => false
    t.integer "committed_hours",      :null => false
    t.integer "normal_hourly_rate",   :null => false
    t.integer "overtime_hourly_rate"
  end

  add_index "role_placements", ["person_id", "role_id", "start_on"], :name => "ak_role_placements", :unique => true

  create_table "role_security_profiles", :force => true do |t|
    t.integer "code_id_security_profile", :null => false
    t.string  "controller_name"
    t.string  "action"
  end

  add_index "role_security_profiles", ["code_id_security_profile", "controller_name", "action"], :name => "ak_role_security_profiles", :unique => true

  create_table "sales_lead_details", :force => true do |t|
    t.integer "sales_lead_id",                        :null => false
    t.string  "client",                               :null => false
    t.text    "notes"
    t.integer "likelihood",           :default => 50
    t.integer "value"
    t.integer "code_id_service_line"
  end

  add_index "sales_lead_details", ["sales_lead_id"], :name => "ak_sales_lead_details", :unique => true

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

  create_table "signatures", :force => true do |t|
    t.integer  "item_id",   :null => false
    t.integer  "person_id", :null => false
    t.integer  "status_id", :null => false
    t.datetime "signed_at"
  end

  add_index "signatures", ["item_id", "person_id", "status_id"], :name => "ak_signatures", :unique => true
  add_index "signatures", ["person_id"], :name => "index_signature_person_ids"

  create_table "status_report_details", :force => true do |t|
    t.integer "status_report_id", :null => false
    t.date    "period_ending_on", :null => false
    t.integer "code_id_traffic",  :null => false
    t.text    "achievements"
    t.text    "support_required"
  end

  add_index "status_report_details", ["status_report_id"], :name => "ak_status_report_details", :unique => true

  create_table "status_report_lines", :force => true do |t|
    t.integer "status_report_id",     :null => false
    t.integer "milestone_id",         :null => false
    t.integer "code_id_traffic",      :null => false
    t.integer "percent_complete",     :null => false
    t.date    "forecast_complete_on"
  end

  add_index "status_report_lines", ["status_report_id", "milestone_id"], :name => "ak_statusreport_lines", :unique => true
  add_index "status_report_lines", ["milestone_id"], :name => "index_statusreport_lines_milestone"

  create_table "status_transitions", :force => true do |t|
    t.string  "type_name",                :null => false
    t.integer "code_id_security_profile", :null => false
    t.integer "status_id_from",           :null => false
    t.integer "status_id_to",             :null => false
  end

  add_index "status_transitions", ["type_name", "code_id_security_profile", "status_id_from", "status_id_to"], :name => "ak_status_transitions", :unique => true

  create_table "statuses", :force => true do |t|
    t.string  "type_name",                       :null => false
    t.string  "value",                           :null => false
    t.string  "generic_stage",                   :null => false
    t.boolean "enabled",       :default => true, :null => false
    t.integer "sequence",      :default => 50,   :null => false
  end

  add_index "statuses", ["type_name", "value"], :name => "ak_statuses", :unique => true
  add_index "statuses", ["type_name", "generic_stage", "enabled"], :name => "index_statuses_generic"

  create_table "subscriptions", :force => true do |t|
    t.integer "item_id",                               :null => false
    t.integer "person_id",                             :null => false
    t.boolean "email_notification", :default => true
    t.boolean "sms_notification",   :default => false
  end

  add_index "subscriptions", ["item_id", "person_id"], :name => "ak_subscriptions", :unique => true

  create_table "system_settings", :force => true do |t|
    t.string "name",        :null => false
    t.string "value"
    t.string "category",    :null => false
    t.text   "explanation"
    t.string "example"
  end

  add_index "system_settings", ["name", "category"], :name => "ak_system_settings_category_name", :unique => true

  create_table "test_case_details", :force => true do |t|
    t.integer "test_case_id",             :null => false
    t.integer "milestone_id_preparation", :null => false
    t.integer "milestone_id_execution",   :null => false
    t.text    "preconditions"
    t.text    "environment_requirements"
    t.text    "data_requirements"
    t.text    "initialisation"
    t.text    "steps"
    t.text    "finalisation"
  end

  create_table "test_case_runs", :force => true do |t|
    t.integer "test_case_id",        :null => false
    t.date    "run_on"
    t.integer "code_id_environment", :null => false
    t.integer "person_id_run_by",    :null => false
    t.integer "milestone_id",        :null => false
    t.integer "code_id_outcome"
  end

  create_table "test_condition_details", :force => true do |t|
    t.string  "test_condition_id",          :null => false
    t.integer "requirement_id"
    t.integer "code_id_type",               :null => false
    t.text    "detail"
    t.integer "milestone_id_phase_covered", :null => false
  end

  create_table "test_observation_details", :force => true do |t|
    t.integer "test_observation_id",           :null => false
    t.text    "steps_to_reproduce"
    t.text    "expected_results"
    t.text    "actual_results"
    t.integer "code_id_severity"
    t.integer "milestone_id_phase_detected"
    t.integer "milestone_id_phase_resolved"
    t.integer "code_id_root_cause"
    t.integer "milestone_id_phase_introduced"
    t.float   "estimated_hours_to_fix"
    t.float   "actual_hours_to_fix"
    t.integer "code_id_functional_area"
    t.string  "external_reference"
  end

  create_table "timesheet_details", :force => true do |t|
    t.integer "timesheet_id",     :null => false
    t.integer "person_id_worker", :null => false
    t.date    "period_ending_on", :null => false
    t.date    "res_approved_on"
  end

  add_index "timesheet_details", ["timesheet_id"], :name => "ak_timesheet_details", :unique => true

  create_table "timesheet_lines", :force => true do |t|
    t.integer "timesheet_id",                :null => false
    t.integer "milestone_id",                :null => false
    t.integer "role_id",                     :null => false
    t.date    "worked_on",                   :null => false
    t.integer "normal_hours",                :null => false
    t.integer "overtime_hours"
    t.integer "uncharged_hours"
    t.integer "hours_estimated_to_complete"
  end

  add_index "timesheet_lines", ["timesheet_id", "milestone_id", "role_id", "worked_on"], :name => "ak_timesheet_lines", :unique => true
  add_index "timesheet_lines", ["milestone_id"], :name => "index_timesheet_lines_milestone_id"

end
