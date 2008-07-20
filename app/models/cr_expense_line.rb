# == Schema Information
# Schema version: 16
#
# Table name: cr_expense_lines
#
#  id                :integer       not null, primary key
#  change_request_id :integer       not null
#  milestone_id      :integer       not null
#  role_id           :integer       not null
#  code_id_purpose   :integer       not null
#  expense_budget    :integer       not null
#

class CrExpenseLine < ActiveRecord::Base
  belongs_to :change_request
  belongs_to :milestone
  belongs_to :role
  belongs_to :purpose_code, :class_name => 'Code', :foreign_key => 'code_id_purpose'
  
  validates_presence_of :change_request_id, :milestone_id, :role_id, :code_id_purpose, :expense_budget
  validates_uniqueness_of :role_id, :scope => [:change_request_id, :milestone_id]
  validates_numericality_of :expense_budget
  validates_inclusion_of :expense_budget, :in => 0..999999999, :message => 'should not be negative'
  validate :validate_purpose_code
  
  protected
  
  def validate_purpose_code
    unless purpose_code.name == 'Purpose' && purpose_code.type_name == 'ChangeRequest'
      errors.add(:code_id_purpose, "is not included in the list")
    end
  end

end
