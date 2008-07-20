# == Schema Information
# Schema version: 16
#
# Table name: project_details
#
#  id                       :integer       not null, primary key
#  project_id               :integer       not null
#  discount_rate            :float         
#  status_report_interval   :integer       
#  res_code_id_billing_plan :integer       
#

class ProjectDetail < ActiveRecord::Base
  include ItemDetail

  belongs_to :project
  
  # validates_presence_of :project_id
  validates_inclusion_of :discount_rate, :allow_nil => true, :in => 0..100, :message => 'should be between 0 and 100'

end
