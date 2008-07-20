# == Schema Information
# Schema version: 16
#
# Table name: test_case_details
#
#  id                       :integer       not null, primary key
#  test_case_id             :integer       not null
#  milestone_id_preparation :integer       not null
#  milestone_id_execution   :integer       not null
#  preconditions            :text          
#  environment_requirements :text          
#  data_requirements        :text          
#  initialisation           :text          
#  steps                    :text          
#  finalisation             :text          
#

class TestCaseDetail < ActiveRecord::Base
  include ItemDetail

  belongs_to :test_case
  
  # validates_presence_of :issue_id
end
