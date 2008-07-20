# == Schema Information
# Schema version: 16
#
# Table name: codes
#
#  id        :integer       not null, primary key
#  type_name :string(255)   not null
#  name      :string(255)   not null
#  value     :string(255)   not null
#  enabled   :boolean       default(true), not null
#  sequence  :integer       default(50), not null
#

# A code is a valid value for a code field within another table. Valid codes are specific
# to a type of item and a code type. The code values are used to populate the valid values
# for the Select Lists on forms.
#
# TODO: B - enable code
class Code < ActiveRecord::Base
    
  validates_presence_of :type_name, :name, :value, :sequence
  validates_inclusion_of :type_name, :in => Status::VALID_TYPE_NAMES
  validates_uniqueness_of :value, :scope => [:type_name, :name]
  validates_numericality_of :sequence, :only_integer => true
  
  # The short form of displaying a code is just it's value.          
  def to_s
    value
  end
  
end
