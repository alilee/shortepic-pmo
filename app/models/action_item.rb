# == Schema Information
# Schema version: 12
#
# Table name: items
#
#  id                    :integer       not null, primary key
#  type                  :string(255)   not null
#  title                 :string(255)   not null
#  project_id            :integer       
#  role_id               :integer       not null
#  person_id             :integer       not null
#  status_id             :integer       not null
#  code_id_priority      :integer       not null
#  project_id_escalation :integer       
#  description           :text          
#  due_on                :date          
#  lft                   :integer       
#  rgt                   :integer       
#  updated_at            :datetime      not null
#  person_id_updated_by  :integer       not null
#  version               :integer       
#  res_idx_fti           :tsvector      
#

# Represents a record in the +items+ table where <tt>type = 'ActionItem'</tt>. It links the 
# specific fields for the ActionItem.
#
# Uses single table inheritance from the +items+ table and links to an ActionItemDetail through 
# a has_one relationship. Each time a new ActionItem is created, the details record is
# created and associated automatically.
#
# TODO: D - Recurring action items?
class ActionItem < Item
  has_one :detail, :class_name => 'ActionItemDetail'

end
