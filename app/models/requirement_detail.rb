# == Schema Information
# Schema version: 12
#
# Table name: requirement_details
#
#  id                       :integer       not null, primary key
#  requirement_id           :integer       not null
#  code_id_requirement_type :integer       not null
#  code_id_requirement_area :integer       not null
#  detail                   :text          
#  person_id_sponsor        :integer       
#  person_id_expert         :integer       
#  requirement_detail_id    :integer       
#  res_lft                  :integer       
#  res_rgt                  :integer       
#

class RequirementDetail < ActiveRecord::Base
  include ItemDetail

  belongs_to :requirement
  belongs_to :item, :foreign_key => 'requirement_id'
  belongs_to :type_code, :class_name => 'Code', :foreign_key => 'code_id_type'
  belongs_to :area_code, :class_name => 'Code', :foreign_key => 'code_id_area'
  
  acts_as_nested_set :parent_column => 'requirement_detail_id', :left_column => 'res_lft', :right_column => 'res_rgt'
  
  validates_presence_of :code_id_type, :code_id_area
end
