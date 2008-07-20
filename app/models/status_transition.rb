# == Schema Information
# Schema version: 16
#
# Table name: status_transitions
#
#  id                       :integer       not null, primary key
#  type_name                :string(255)   not null
#  code_id_security_profile :integer       not null
#  status_id_from           :integer       not null
#  status_id_to             :integer       not null
#

class StatusTransition < ActiveRecord::Base

  belongs_to :security_profile_code, :class_name => 'Code', :foreign_key => 'code_id_security_profile'
  belongs_to :status_from, :class_name => 'Status', :foreign_key => 'status_id_from'
  belongs_to :status_to, :class_name => 'Status', :foreign_key => 'status_id_to'

  validates_presence_of :type_name
  validates_inclusion_of :type_name, :in => Status::VALID_TYPE_NAMES
  validates_uniqueness_of :code_id_security_profile, :scope => [:type_name, :status_id_from, :status_id_to]
  validate :status_values
  
  # Find all transitions for the given type_name, profile ids, and status starting points.  
  def self.find_all_valid(target_type_name, code_id_profiles, target_status_id_from)
    StatusTransition.find(:all,
      :conditions => ['type_name = ? and 
        code_id_security_profile in (0,?) and 
        status_id_from in (0,?)', 
          target_type_name, code_id_profiles, target_status_id_from])
  end  
  
  protected
  
  # Validate status values entered are valid for the type of item.
  #
  # Display an error message if either of the status fields has a value and its type_name does not match the type of
  # item (e.g. StatusReport). Also check that the two statuses are not the same.
  def status_values
    unless (status_from.nil? || status_from.type_name == self.type_name)
      errors.add(:status_id_from, "is not included in the list")
    end
    unless (status_to.nil? || status_to.type_name == self.type_name)
      errors.add(:status_id_to, "is not included in the list")
    end
    unless ((status_from.nil? && status_to.nil?) || status_id_from != status_id_to)
      errors.add(:status_id_to, "cannot be the same as the from status")
    end
  end
  
end
