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

# Linked requirements and test conditions have a special meaning - they are 
# covered by the test case.
class TestCase < Item
  has_one :detail, :class_name => 'TestCaseDetail'
  has_many :execution_runs, :class_name => 'TestCaseRun', :dependent => :destroy
  
end
