# == Schema Information
# Schema version: 16
#
# Table name: meeting_details
#
#  id         :integer       not null, primary key
#  meeting_id :integer       not null
#  start_at   :datetime      
#  finish_at  :datetime      
#  location   :string(255)   
#  resolved   :text          
#

class MeetingDetail < ActiveRecord::Base
  include ItemDetail

  belongs_to :meeting
  
  # validates_presence_of :issue_id
end
