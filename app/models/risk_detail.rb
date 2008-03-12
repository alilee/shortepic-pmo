# == Schema Information
# Schema version: 12
#
# Table name: risk_details
#
#  id                      :integer       not null, primary key
#  risk_id                 :integer       not null
#  code_id_pre_likelihood  :integer       
#  code_id_pre_impact      :integer       
#  code_id_strategy        :integer       
#  strategy                :text          
#  code_id_post_likelihood :integer       
#  code_id_post_impact     :integer       
#

class RiskDetail < ActiveRecord::Base
  include ItemDetail

  belongs_to :risk
  
  # validates_presence_of :issue_id
end
