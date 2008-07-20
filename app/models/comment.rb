# == Schema Information
# Schema version: 16
#
# Table name: comments
#
#  id         :integer       not null, primary key
#  item_id    :integer       not null
#  body       :text          not null
#  created_at :datetime      not null
#  person_id  :integer       not null
#

class Comment < ActiveRecord::Base
  belongs_to :item
  belongs_to :person
  
  validates_presence_of :item_id, :person_id, :body

end
