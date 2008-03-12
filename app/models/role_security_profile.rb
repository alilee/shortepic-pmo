# == Schema Information
# Schema version: 12
#
# Table name: role_security_profiles
#
#  id                       :integer       not null, primary key
#  code_id_security_profile :integer       not null
#  controller_name          :string(255)   
#  action                   :string(255)   
#

class RoleSecurityProfile < ActiveRecord::Base
  belongs_to :security_profile_code, :class_name => 'Code', :foreign_key => 'code_id_security_profile'
  
  validates_presence_of :code_id_security_profile
  
  # Determine if the profile id is authorised to access the given function.
  #
  # Null in the record is interpreted as a wildcard match.
  def self.profile_matches?(code_id_security_profile, cont_name, action)
    return 0 < RoleSecurityProfile.count(:conditions => ['
        (code_id_security_profile = ?) and
        (controller_name = ? or controller_name is null) and 
        (action = ? or action is null)', 
        code_id_security_profile, 
        cont_name, 
        action])
  end
  
end
