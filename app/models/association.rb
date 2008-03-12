# == Schema Information
# Schema version: 12
#
# Table name: associations
#
#  id           :integer       not null, primary key
#  item_id_from :integer       not null
#  item_id_to   :integer       not null
#

class Association < ActiveRecord::Base
  belongs_to :item_from, :class_name => "Item", :foreign_key => "item_id_from"
  belongs_to :item_to, :class_name => "Item", :foreign_key => "item_id_to"
  
  validates_presence_of :item_id_from, :item_id_to
  validates_uniqueness_of :item_id_to, :scope => 'item_id_from'
end
