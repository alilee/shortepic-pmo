# == Schema Information
# Schema version: 16
#
# Table name: release_details
#
#  id                      :integer       not null, primary key
#  release_id              :integer       not null
#  deployment_instructions :text          
#  rollback_instructions   :text          
#

class ReleaseDetail < ActiveRecord::Base
  include ItemDetail

  belongs_to :release
  belongs_to :item, :foreign_key => 'release_id'    
end
