# == Schema Information
# Schema version: 16
#
# Table name: action_item_details
#
#  id                   :integer       not null, primary key
#  action_item_id       :integer       not null
#  code_id_environment  :integer       not null
#  starting_at          :datetime      
#  start_signal         :string(255)   
#  target_complete_at   :datetime      
#  forecast_complete_at :datetime      
#  update_interval      :string(255)   
#  contingency_plan     :text          
#  use_contingency_at   :datetime      
#

class ActionItemDetail < ActiveRecord::Base
  include ItemDetail
  
  belongs_to :action_item
  
  # validates_presence_of :action_item_id
end
