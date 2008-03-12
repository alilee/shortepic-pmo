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

# TODO: C - Decision as a quality-domain object?
class Requirement < Item
  has_one :detail, :class_name => 'RequirementDetail'
  
  
  def update_nested_sets(old_item, item_was_new_record)
    super
    
    detail.move_to_child_of(detail.parent) if 
		( (item_was_new_record && !detail.parent.nil?) || 
		  (!item_was_new_record && (old_item.detail.requirement_detail_id_parent || 0) != (detail.requirement_detail_id_parent || 0))
		)
  end
end
