# == Schema Information
# Schema version: 16
#
# Table name: role_placements
#
#  id                   :integer       not null, primary key
#  person_id            :integer       not null
#  role_id              :integer       not null
#  start_on             :date          not null
#  end_on               :date          not null
#  committed_hours      :integer       not null
#  normal_hourly_rate   :integer       not null
#  overtime_hourly_rate :integer       
#

class RolePlacement < ActiveRecord::Base
  belongs_to :person
  belongs_to :role
  
  validates_presence_of :person_id, :role_id, :start_on, :end_on
  validates_uniqueness_of :start_on, :scope => [:role_id, :person_id] 
  validates_numericality_of :committed_hours
  validates_inclusion_of :committed_hours, :in => 0..99999, :message => 'should not be negative'
  validates_inclusion_of :normal_hourly_rate, :in => 0..999999, :message => 'should be positive'
  validates_inclusion_of :overtime_hourly_rate, :allow_nil => true, :in => 0..999999, :message => 'should be positive'
  validate :validate_end_on
  
  protected
  
  def validate_end_on
    if start_on >= end_on
      errors.add(:end_on, "should be later than the start")
    end
  end
  
end
