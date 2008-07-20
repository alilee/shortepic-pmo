# == Schema Information
# Schema version: 16
#
# Table name: statuses
#
#  id            :integer       not null, primary key
#  type_name     :string(255)   not null
#  value         :string(255)   not null
#  generic_stage :string(255)   not null
#  enabled       :boolean       default(true), not null
#  sequence      :integer       default(50), not null
#

require 'set'

# TODO: B - status transitions we need it.
class Status < ActiveRecord::Base
  
  NIL = '0-nil'
  NEW = '1-new' 
  PENDING = '2-pending'
  IN_PROGRESS = '3-in progress'
  REVIEW = '4-review' 
  COMPLETE = '5-complete'
  WITHDRAWN = '6-withdrawn'

  VALID_GENERIC = [
    NIL,
    NEW,
    PENDING, 
    IN_PROGRESS,
    REVIEW,
    COMPLETE,
    WITHDRAWN
  ]

  DOMAIN_TYPES = {
    'Team' => [ Project, Role, Person ],
    'Operations' => [ Issue, ActionItem, Milestone, StatusReport, Absence, Risk, Meeting ],
    'Financial' => [ ChangeRequest, Timesheet ],
    'Quality' => [ Requirement, TestCondition, TestCase, TestObservation ],
    'Configuration' => [ Component, Release ]
  }

  VALID_TYPES = DOMAIN_TYPES.values.flatten
  VALID_TYPE_NAMES = VALID_TYPES.collect {|c| c.name}.sort

  validates_presence_of :type_name, :value, :generic_stage, :sequence
  validates_inclusion_of :generic_stage, :in => VALID_GENERIC
  validates_inclusion_of :type_name, :in => VALID_TYPE_NAMES
  validates_numericality_of :sequence, :only_integer => true
  
  validates_uniqueness_of :value, :scope => 'type_name'
  
  def <=>(other)
    if self.type_name == other.type_name
      if self.generic_stage == other.generic_stage then
        self.value <=> other.value
      else
        self.generic_stage <=> other.generic_stage
      end
    else
      self.type_name <=> other.type_name
    end
  end
  
  def self.alive
    VALID_GENERIC - [NIL, WITHDRAWN]    
  end
  
  def self.incomplete
    self.alive - [COMPLETE]
  end
  
  def incomplete?
    Status.incomplete.include? generic_stage
  end
  
  def self.in_progress 
    self.incomplete - [NEW, PENDING]
  end
  
  def self.formative
    [NEW, PENDING]
  end
      
  def to_s
    value
  end
  
end
