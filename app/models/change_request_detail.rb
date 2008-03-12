# == Schema Information
# Schema version: 12
#
# Table name: change_request_details
#
#  id                :integer       not null, primary key
#  change_request_id :integer       not null
#  background        :text          
#  res_approved_on   :date          
#

class ChangeRequestDetail < ActiveRecord::Base
  include ItemDetail
  
  belongs_to :ChangeRequest
  
  # validates_presence_of :change_request_id
  
  attr_protected :res_approved_on
end
