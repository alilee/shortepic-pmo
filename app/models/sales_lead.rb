# == Schema Information
# Schema version: 16
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
#  res_idx_fti           :string        
#

# Represents a record in the +items+ table where <tt>type = 'SalesLead'</tt>. It links the 
# specific fields for the SalesLead.
#
# Uses single table inheritance from the +items+ table and links to an SalesLeadDetail through 
# a has_one relationship. Each time a new SalesLead is created, the details record is
# created and associated automatically.
#
class SalesLead < Item
  has_one :detail, :class_name => 'SalesLeadDetail'

end
