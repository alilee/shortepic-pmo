# == Schema Information
# Schema version: 12
#
# Table name: person_contacts
#
#  id              :integer       not null, primary key
#  person_id       :integer       not null
#  code_id_contact :integer       not null
#  address         :string(255)   not null
#

class PersonContact < ActiveRecord::Base
  belongs_to :person
  belongs_to :contact_code, :class_name => 'Code', :foreign_key => 'code_id_contact'
  
  validates_presence_of :person_id, :code_id_contact, :address
  validates_uniqueness_of :address, :scope => [:code_id_contact, :person_id] 
  validate :validate_contact_code
  
  protected
  
  def validate_contact_code
    unless contact_code.name == 'Contact' && contact_code.type_name == 'Person'
      errors.add(:code_id_contact, "is not included in the list")
    end
  end

end
