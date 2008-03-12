# == Schema Information
# Schema version: 12
#
# Table name: milestone_details
#
#  id           :integer       not null, primary key
#  milestone_id :integer       not null
#  deadline_on  :date          
#

# Details for a Milestone Item. A Milestone has three key dates: the 
# baseline, which comes from the most recently approved change request,
# the forecast, which comes from the most recently approved status report,
# and the deadline, which is in the MilestoneDetail record.
# 
# TODO: B - deadline for milestone
class MilestoneDetail < ActiveRecord::Base
  include ItemDetail

  belongs_to :milestone
  
  # validates_presence_of :milestone_id
end
