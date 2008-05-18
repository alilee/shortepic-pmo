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

# A Milestone is a cost object. Budget is set through ChangeRequest and actuals through
# Timesheet and ExpenseClaim.
#
# TODO: B - Baselines must be protected from CRs raised below the milestone in the project tree.
# TODO: B - Should add dependendencies and roadmap view
class Milestone < Item
  has_one :detail, :class_name => 'MilestoneDetail'
  
  has_many :successor_dependencies, :class_name => 'MilestoneDependency', :foreign_key => 'milestone_id_predecessor', :include => :successor, :dependent => :destroy
  has_many :predecessor_dependencies, :class_name => 'MilestoneDependency', :foreign_key => 'milestone_id', :include => :predecessor, :dependent => :destroy
  has_many :cr_expense_lines, :dependent => :destroy
  has_many :cr_effort_lines, :dependent => :destroy
  has_many :cr_date_lines, :dependent => :destroy
  has_many :timesheet_lines, :dependent => :destroy
  has_many :status_report_lines, :dependent => :destroy
  has_many :detected_test_observation_details, :class_name => 'TestObservationDetail', :foreign_key => 'milestone_id_phase_detected', :include => {:test_observation => :status}, :order => 'statuses.sequence, items.code_id_priority', :dependent => :destroy
  
  has_one :last_status_report_line, 
    :class_name => 'StatusReportLine', 
    :include => { :status_report => [:detail, :status] }, 
    :conditions => ['generic_stage = ?', Status::COMPLETE], 
    :order => 'period_ending_on DESC'
    
  def baseline_date_line
    CrDateLine.find_by_milestone_id(id, 
      :include => {:change_request => [:status, :detail]}, 
      :conditions => ["generic_stage = ?", Status::COMPLETE], 
      :order => 'res_approved_on DESC')
  end
  
  def baseline_ends_on
    dateline = baseline_date_line
    dateline && dateline.end_on
  end

  def approved_effort_lines
    CrEffortLine.find_all_by_milestone_id(id, 
      :include => [:role, {:change_request => :status}], 
      :conditions => ["generic_stage = ?", Status::COMPLETE])
  end
  
  def approved_expense_lines
    CrExpenseLine.find_all_by_milestone_id(id,
      :include => {:change_request => :status},
      :conditions => ['generic_stage = ?', Status::COMPLETE])
  end

end
