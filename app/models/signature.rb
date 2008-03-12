# == Schema Information
# Schema version: 12
#
# Table name: signatures
#
#  id        :integer       not null, primary key
#  item_id   :integer       not null
#  person_id :integer       not null
#  status_id :integer       not null
#  signed_at :datetime      
#

class Signature < ActiveRecord::Base
  belongs_to :item
  belongs_to :status
  belongs_to :person
  
  validates_uniqueness_of :status_id, :scope => [:item_id, :person_id]
  validates_presence_of :person_id, :item_id, :status_id
  validate :validate_status
  
  def sign(time = Time.now)
    self.signed_at = time
  end
  
  protected
  
  def validate_status
    unless status.type_name == item.class.name
      errors.add(:status_id, "is not included in the list")
    end
  end
  
end
