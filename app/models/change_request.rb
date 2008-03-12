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

class ChangeRequest < Item
  has_one :detail, :class_name => 'ChangeRequestDetail'

  has_many :effort_lines, :class_name => 'CrEffortLine', :include => [:milestone, :role], :dependent => :destroy
  has_many :expense_lines, :class_name => 'CrExpenseLine', :include => [:milestone, :role], :dependent => :destroy
  has_many :date_lines, :class_name => 'CrDateLine', :include => [:milestone], :dependent => :destroy

  belongs_to :project
  
  before_validation :update_approved_on

  def total_effort_hours
    effort_lines.sum(:hours)
  end
  
  def total_effort_budget
    effort_lines.sum(:effort_budget)
  end

  def total_expense_budget
    expense_lines.sum(:expense_budget)
  end
  
  protected
  
  # If we are saving the CR as a complete status, then note todays date.
  def update_approved_on
		if status && status.generic_stage == Status::COMPLETE && detail.res_approved_on.nil?
		  detail.res_approved_on = Date.today 
		end		
  end
  
end
