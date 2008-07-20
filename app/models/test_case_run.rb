# == Schema Information
# Schema version: 16
#
# Table name: test_case_runs
#
#  id                  :integer       not null, primary key
#  test_case_id        :integer       not null
#  run_on              :date          
#  code_id_environment :integer       not null
#  person_id_run_by    :integer       not null
#  milestone_id        :integer       not null
#  code_id_outcome     :integer       
#

class TestCaseRun < ActiveRecord::Base
  belongs_to :test_case
  
end
