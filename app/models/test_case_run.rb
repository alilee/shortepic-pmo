# == Schema Information
# Schema version: 12
#
# Table name: test_case_runs
#
#  id                        :integer       not null, primary key
#  test_case_id              :integer       not null
#  run_on                    :date          
#  person_id_run_by          :integer       not null
#  milestone_id              :integer       not null
#  code_id_test_case_outcome :integer       
#

class TestCaseRun < ActiveRecord::Base
  belongs_to :test_case
  
end
