# == Schema Information
# Schema version: 16
#
# Table name: component_details
#
#  id                         :integer       not null, primary key
#  component_id               :integer       not null
#  component_detail_id_parent :integer       
#  res_lft                    :integer       
#  res_rgt                    :integer       
#  code_id_type               :integer       not null
#

class ComponentDetail < ActiveRecord::Base
  include ItemDetail

  belongs_to :component
  belongs_to :item, :foreign_key => 'component_id'  
  belongs_to :type_code, :class_name => 'Code', :foreign_key => 'code_id_type'
  
  acts_as_nested_set :parent_column => 'component_detail_id_parent', :left_column => 'res_lft', :right_column => 'res_rgt'
  
  validates_presence_of :code_id_type
end
