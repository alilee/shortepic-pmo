# == Schema Information
# Schema version: 16
#
# Table name: subscriptions
#
#  id                 :integer       not null, primary key
#  item_id            :integer       not null
#  person_id          :integer       not null
#  email_notification :boolean       default(true)
#  sms_notification   :boolean       
#

# Records a person's interest in an item so they can be notified if it changes. A person's 
# favourites view lists all the objects that the person is monitoring.
#
# TODO: C - add flags for email and sms notification on change.
class Subscription < ActiveRecord::Base
    belongs_to :item
    belongs_to :person
    validates_presence_of :item_id, :person_id
    validates_uniqueness_of :person_id, :scope => :item_id
end
