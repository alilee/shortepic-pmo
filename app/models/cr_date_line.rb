# == Schema Information
# Schema version: 12
#
# Table name: cr_date_lines
#
#  id                :integer       not null, primary key
#  change_request_id :integer       not null
#  milestone_id      :integer       not null
#  start_on          :date          not null
#  end_on            :date          not null
#

class CrDateLine < ActiveRecord::Base
  belongs_to :change_request
  belongs_to :milestone
  
  validates_presence_of :change_request_id, :milestone_id, :start_on, :end_on
  validates_uniqueness_of :milestone_id, :scope => 'change_request_id'
  validate :validate_ends_after_start
  
  protected
  
  def validate_ends_after_start
    return if start_on.nil? || end_on.nil?
    if end_on <= start_on
      errors.add(:end_on, "should be after start")
    end
  end

end
