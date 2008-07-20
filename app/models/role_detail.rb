# == Schema Information
# Schema version: 16
#
# Table name: role_details
#
#  id                       :integer       not null, primary key
#  role_id                  :integer       not null
#  skills                   :text          
#  experience               :text          
#  accountabilities         :text          
#  responsibilities         :text          
#  code_id_security_profile :integer       not null
#

class RoleDetail < ActiveRecord::Base
  include ItemDetail

  belongs_to :role
  belongs_to :security_profile_code, :class_name => 'Code', :foreign_key => 'code_id_security_profile'
  
  # validates_presence_of :role_id
  validates_presence_of :code_id_security_profile
end
