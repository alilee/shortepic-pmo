# == Schema Information
# Schema version: 16
#
# Table name: milestone_dependencies
#
#  id                       :integer       not null, primary key
#  milestone_id             :integer       not null
#  milestone_id_predecessor :integer       not null
#  code_id_dependency_type  :integer       not null
#  is_critical              :boolean       
#

class MilestoneDependency < ActiveRecord::Base
  belongs_to :predecessor, :class_name => 'Milestone', :foreign_key => 'milestone_id_predecessor'
  belongs_to :successor, :class_name => 'Milestone', :foreign_key => 'milestone_id'
  belongs_to :dependency_type_code, :class_name => 'Code', :foreign_key => 'code_id_dependency_type'

  validates_presence_of :milestone_id_predecessor, :milestone_id, :code_id_dependency_type
end
