# == Schema Information
# Schema version: 12
#
# Table name: meeting_attendees
#
#  id         :integer       not null, primary key
#  meeting_id :integer       not null
#  person_id  :integer       not null
#

class MeetingAttendee < ActiveRecord::Base
  belongs_to :person
  belongs_to :meeting
  
  validates_presence_of :person_id, :meeting_id
  validates_uniqueness_of :meeting_id, :scope => [:person_id] 
  
end
