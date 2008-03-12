# == Schema Information
# Schema version: 12
#
# Table name: attachment_contents
#
#  id            :integer       not null, primary key
#  data          :binary        
#  attachment_id :integer       not null
#

class AttachmentContent < ActiveRecord::Base
  belongs_to :attachment
  validates_presence_of :attachment_id, :data
end
