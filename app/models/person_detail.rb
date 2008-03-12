# == Schema Information
# Schema version: 12
#
# Table name: person_details
#
#  id                :integer       not null, primary key
#  person_id         :integer       not null
#  email             :string(255)   not null
#  code_id_timezone  :integer       not null
#  res_password_hash :string(255)   not null
#  res_password_salt :string(255)   not null
#  reset_next_login  :boolean       default(true)
#  res_cc_name       :string(255)   
#  res_cc_num        :string(255)   
#  res_cc_ccv        :integer       
#  res_cc_mon        :integer       
#  res_cc_year       :integer       
#

# Represents a record in the +person_details+ table
#
# This table links back to the +items+ table where the type of item is 'Person'.  This table is
# automatically populated when the Person is created.
#
# TODO: C - personal preference for timezone, and updates to initial and test data including codes
class PersonDetail < ActiveRecord::Base
  include ItemDetail
  
  belongs_to :person
  belongs_to :timezone_code, :class_name => 'Code', :foreign_key => 'code_id_timezone'
  
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_presence_of :res_password_hash, :res_password_salt, :code_id_timezone
  validates_uniqueness_of :email
  
  attr_protected :res_password_salt, :res_password_hash
  
  def initialize(*args)
    super(*args)
    new_password = PersonDetail.random_password()
    self.res_password_salt = rand(1 << 32).to_s(16)
    self.res_password_hash = Person.hash_password(new_password, self.res_password_salt)
  end
  
  # Set the users password and record it in a secure fashion 
  def set_password(new_password)
    self.res_password_salt = rand(1 << 32).to_s(16)
    self.res_password_hash = Person.hash_password(new_password, self.res_password_salt)
    save!
  end
  
  # Set the users password to a new random value and advise via email
  def reset_password
    new_password = PersonDetail.random_password()
    set_password(new_password)
    SubscriptionMailer.deliver_inform_password(person.full_email, new_password) 
  end

  protected
  
  # Create a new random password
  #
  # Uses apg to generate reasonable length pronouncable passwords.
  # -n number of passwords to generate
  # -a algorithm (0 for pronouncable)
  # -m minimum length
  # -q quiet
  def self.random_password
    `apg -n 1 -a 0 -m 9 -q`.strip
  end 
    
end
