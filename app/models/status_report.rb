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

# A status report is an item that details how
# the parent item (e.g a project) is going in terms
# of tracking. A status report tracks against
# any number of milestones in the project. This tracking
# handled how much more time is required to complete the 
# milestone along with its status (using traffic light).
#
# Status reports can collect status for milestones here or escalated here. Usually, a status report would be created for sub-projects, however
# the extents of the tree may not warrant a status report, but may allow convenient organisation of milestones.
class StatusReport < Item
  has_one :detail, :class_name => 'StatusReportDetail'

  has_many :status_report_lines, :dependent => :destroy
  
end
