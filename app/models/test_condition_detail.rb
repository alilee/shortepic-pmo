# == Schema Information
# Schema version: 16
#
# Table name: test_condition_details
#
#  id                         :integer       not null, primary key
#  test_condition_id          :string(255)   not null
#  requirement_id             :integer       
#  code_id_type               :integer       not null
#  detail                     :text          
#  milestone_id_phase_covered :integer       not null
#

class TestConditionDetail < ActiveRecord::Base
  include ItemDetail

  belongs_to :test_condition
  
  validates_presence_of :code_id_type, :milestone_id_phase_covered
end
