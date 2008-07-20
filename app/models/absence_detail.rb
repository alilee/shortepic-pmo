# == Schema Information
# Schema version: 16
#
# Table name: absence_details
#
#  id                   :integer       not null, primary key
#  absence_id           :integer       not null
#  person_id            :integer       not null
#  away_on              :date          not null
#  back_on              :date          not null
#  code_id_availability :integer       not null
#

# Contents of the details record attached to an absence item.
#
class AbsenceDetail < ActiveRecord::Base
  include ItemDetail
  
  belongs_to :absence
  belongs_to :person
  belongs_to :availability_code, :class_name => 'Code', :foreign_key => 'code_id_availability'
  
  validates_presence_of :away_on, :back_on, :person_id, :code_id_availability
  validate :availability_code_values, :ordering_of_dates
  
  protected
  
  # Validate availability code entered is valid.
  #
  # Invalid and error if code is not an availability code.
  def availability_code_values
    unless (availability_code && availability_code.type_name == 'Absence' && availability_code.name == 'Availability')
      errors.add(:code_id_availability, "is not included in the list")
    end
  end
  
  # Validate that away date is before back date.
  #
  def ordering_of_dates
    if back_on && away_on && back_on < away_on 
      errors.add(:back_on, "must not be before start of absence")
    end
  end
  
end
