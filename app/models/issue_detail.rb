# == Schema Information
# Schema version: 16
#
# Table name: issue_details
#
#  id             :integer       not null, primary key
#  issue_id       :integer       not null
#  background     :text          
#  alternatives   :text          
#  recommendation :text          
#

class IssueDetail < ActiveRecord::Base
  include ItemDetail

  belongs_to :issue
  
  # validates_presence_of :issue_id
end
