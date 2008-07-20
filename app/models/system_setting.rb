# == Schema Information
# Schema version: 16
#
# Table name: system_settings
#
#  id          :integer       not null, primary key
#  name        :string(255)   not null
#  value       :string(255)   
#  category    :string(255)   not null
#  explanation :text          
#  example     :string(255)   
#

require 'set'

class SystemSetting < ActiveRecord::Base

  VALID_CATEGORIES = ['Links', 
    'Traffic lights', 
    'Mail server'
  ] # This is not validated as final list will emerge from development
  
  validates_presence_of :name, :category
  validates_uniqueness_of :name, :scope => :category
  
  def <=>(other)
    if self.category == other.category
      then self.name <=> other.name
    else
      self.category <=> other.category
    end
  end
  
  def self.system_setting(category, name, default = nil)
    s = SystemSetting.find_or_create_by_category_and_name(category, name)
    if s.value.nil? && !default.nil?
      s.value = default
      s.save!     
    end
    s.value
  end
  
end
