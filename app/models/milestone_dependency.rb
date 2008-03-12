class MilestoneDependency < ActiveRecord::Base
  belongs_to :predecessor, :class_name => 'Milestone', :foreign_key => 'milestone_id_predecessor'
  belongs_to :successor, :class_name => 'Milestone', :foreign_key => 'milestone_id'
  belongs_to :dependency_type_code, :class_name => 'Code', :foreign_key => 'code_id_dependency_type'

  validates_presence_of :milestone_id_predecessor, :milestone_id, :code_id_dependency_type
end
