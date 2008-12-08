# == Schema Information
# Schema version: 16
#
# Table name: items
#
#  id                    :integer       not null, primary key
#  type                  :string(255)   not null
#  title                 :string(255)   not null
#  project_id            :integer       
#  role_id               :integer       not null
#  person_id             :integer       not null
#  status_id             :integer       not null
#  code_id_priority      :integer       not null
#  project_id_escalation :integer       
#  description           :text          
#  due_on                :date          
#  lft                   :integer       
#  rgt                   :integer       
#  updated_at            :datetime      not null
#  person_id_updated_by  :integer       not null
#  version               :integer       
#  res_idx_fti           :string        
#

require 'acts_as_versioned'

# Item is the foundation for six generic features (Comment, Link, Attachment, Subscription, 
# Signature, Security).  These features are inherited by specialisations of Item called
# item types (e.g. Person).  New types of items can be easily introduced into the
# application with minimal coding effort using single table inheritance classes.
# 
# This is implemented using the +items+ table.  Each row in the +items+ table must be of specific
# item type (e.g. Person)  The +items+ table has relationships to other tables such as +comments+ and
# +attachments+.  By default, all classes that inherit from Item, also inherit these relationships.
# Where specific information needs to be recorded about a particular type of item a '+_details+' table
# is used (e.g. +person_details+) to which the relationship is specified in the class inherited from Item. For
# example the Person class defines the relationship to PersonDetail.
#
# TODO: C - change to use polymorphic associations
# TODO: B - links should be ordered by priority, due_on
class Item < ActiveRecord::Base

  has_many :comments, :order => 'created_at', :dependent => :destroy
  has_many :associations_to, :class_name => 'Association', :foreign_key => 'item_id_to', :include => 'item_from', :dependent => :destroy
  has_many :associations_from, :class_name => 'Association', :foreign_key => 'item_id_from', :include => { :item_to => [:status, :priority_code] }, :order => 'codes.sequence', :dependent => :destroy
  has_many :attachments, :dependent => :destroy, :order => 'lower(filename) ASC, version DESC'
  has_many :subscriptions, :include => {:person => :detail}, :dependent => :destroy
  has_many :signatures, :include => [:status, :person], :order => 'generic_stage ASC, signed_at', :dependent => :destroy

  belongs_to :status
  belongs_to :role
  belongs_to :person
  belongs_to :priority_code, :class_name => 'Code', :foreign_key => 'code_id_priority'
  belongs_to :escalation, :class_name => 'Project', :foreign_key => 'project_id_escalation'
  belongs_to :updated_by, :class_name => 'Person', :foreign_key => 'person_id_updated_by'
  belongs_to :parent, :class_name => 'Project', :foreign_key => 'project_id'
  
  acts_as_versioned
  self.non_versioned_columns << 'lft' << 'rgt' << 'res_idx_fti'
  
  validates_presence_of :title, :role_id, :person_id, :status_id, :code_id_priority, :person_id_updated_by
  validates_uniqueness_of :title, :scope => :project_id
  validate :esc_values, :priority_code_values, :status_values, :parent_type
  validates_associated :detail
  
  before_save :fix_escalation
  after_save :notify_subscribers

  # Create and associate the details record automatically on new.
  def self.new(*args)
    result = super(*args)
    result.build_detail
    result
  end
  
  def ancestor_projects
    (new_record? || parent.nil?) ? [] : parent.self_and_ancestors
  end
  
  # Return this item's governing projects. This equals all the ancestors, plus myself - if I am a project.
  #
  # Use Project nested set routines for speed. The item could be new, so project ancestors will not work
  # in which case we use the parents. The parent must not be new. If the project is a root project then 
  # the result is the empty set.
  def governing_projects
    project = self
    if self.class != Project || project.new_record?
      project = self.parent
    end
    return project.nil? ? [] : project.self_and_ancestors
  end
  
  def governing_project_ids
    project = self
    if self.class != Project || project.new_record?
      project = self.parent
    end
    return project.nil? ? [] : project.self_and_ancestor_ids
  end
  
  # When an item is moved from one project to another (i.e. the item's parent project is changed) it may be
  # necessary to update what project the item has been escalated to.  There are 2 scenarios where the escalation
  # will need to change:
  # 1. The item is a project and the project no longer has a parent project.
  # 2. The item is moved to different project and the new project belongs to a different branch of the project tree.
  #
  # If the new parent project id for the project is null (i.e. the project is now a root project), this method sets
  # the escalation project id for the item to null.
  # If the new parent project for the item is now different to the escalation project id and the escalation
  # project id does not match any of the ancestors for the new parent project then the escalation project id is set
  # to the parent project id.
  #
  # TODO: B - Incorporate into controller logic or as a before_save callback.
  # TODO: B - Need to update the project escalation for children of the item.
  def reset_escalation_if_necessary
    # Remember the parent is the new parent, may not be saved yet. Be careful when going to ancestors.
    result = false
    new_parent = parent
    if new_parent.nil? || ((escalation.id != new_parent.id) && !new_parent.ancestors.include?(escalation))
      self.escalation = new_parent
      result = true
    end
    result
  end

  # Groups and sorts attachments by filename for the item.
  #
  # For the item's attachments, returns a hash with key = filename and value = alphabetically ordered set of Attachment
  # objects for each filename.
  def attachments_grouped_by_filename
    sorted_attachments = SortedSet.new(attachments)
    sorted_attachments.classify{|a| a.filename}
  end
  
  # Check if the person object passed in is subscribed to this item.
  # 
  # The subscription object is located using the item_id and person_id.  If no subscription is found then
  # return false.
  def subscribed?(person)
    subscription = Subscription.find_by_item_id_and_person_id(self.id, person.id)
    !subscription.nil?
  end
  
  # Return an array of hashes of the field changes in each version of this item.
  # 
  # Step through the versions and for each return a hash of the attributes and their values for each change. 
  def version_diffs
    last = Hash.new
    results = Array.new
    versions.each do |v|
      diffs = Hash.new
      versioned_attributes.each do |a|
        if v.attributes[a] != last[a] then
          diffs[a] = last[a] = v.attributes[a]
        end
      end
      diffs['person_id_updated_by'] = v.attributes['person_id_updated_by']
      results << diffs
    end
    results
  end
  
  # Return true if the due date has past for this item
  def overdue?
    due_on && due_on < Date.today
  end
  
  # Is this item escalated up from the given project?
  #
  # Assumes that the project is an ancestor of the item and that it has been escalated at least that far.
  def escalated_up?(above_project)
    above_project.id != self.project_id_escalation
  end
  
  # Is this item escalated here from below the given project?
  #
  # Assumes that the project is an ancestor of the item and that it has been escalated at least that far.
  def escalated_here?(to_project)
    to_project.id != self.project_id
  end
  
  def update_nested_sets(old_item, item_was_new_record)
    # 1. if its not a project then its not in the hierarchy
		# 2. otherwise if its a new project in the tree then move it
		# 3. otherwise if its an existing project and its moving (maybe from root)
		self.move_to_child_of(self.parent) if self.class == Project && 
		( (item_was_new_record && !self.parent.nil?) || 
		  (!item_was_new_record && (old_item.project_id || 0) != (self.project_id || 0))
		)
  end
  
  # Return a string in CSV format containing the details of the object
  def to_csv
    csv_comments = "No comments" # comments.collect { |c| "[#{c.person.title} at #{c.created_at.to_formatted_s(:short)}] #{c.body}" }.join("\n\n")
    a = [ id, type, title, parent.title, role.title, person.title, status, priority_code, escalation.title, description, due_on, version, updated_at.to_date, updated_by.title, first_version_updated_at.to_date, first_version_updated_by.title, csv_comments ]
    CSV.generate_line(a)
  end
  
  def self.to_csv_header
    a = [ 'id', 'type', 'title', 'parent', 'role', 'person', 'status', 'priority_code', 'escalation', 'description', 'due_on', 'version', 'updated_on', 'updated_by', 'created_on', 'created_by', 'comments' ]
    CSV.generate_line(a)
  end
  
  def first_version_updated_by
    old_version = find_version(1)
    Person.find(old_version.person_id_updated_by)
  end

  def first_version_updated_at
    old_version = find_version(1)
    old_version.updated_at
  end
  
  protected
  
  # If the object is attempted to be saved with an escalation of 0 then correct it be the same as
  # the parent. This enables zero as an escalation to mean no escalation.
  def fix_escalation
    if project_id_escalation.nil? || project_id_escalation == 0 then
      self.project_id_escalation = project_id
    end
  end
  
  # For each subscriber to the item, send an email notifying the subscribing person of a change to the item.
  #
  # Subscription objects are retrieved for the current item.  For each subscription object, the person object 
  # (related to the subscription) and item object are then passed through to the method that delivers the email
  # notification.
  def notify_subscribers
    recipients = subscriptions.collect {|s| s.person.full_email }
    SubscriptionMailer.deliver_user_notification(recipients, self) unless recipients.empty?
  end
  
  # Validate that the project the item is escalated to is on the same branch as the parent project for that item
  # and that a root project cannot be escalated.
  #
  # If the parent project id for the project is not null, this method displays an error message if the escalation
  # project id is null or the escalation project id does not match the parent project id or any of the ancestors
  # of the parent project id.
  # If the parent project id is null (i.e. the item is a root project) and an escalation project id has been
  # assigned, an error message is displayed.
  def esc_values
    if (parent)
      if (escalation.nil?) || ((parent.id != escalation.id) && !parent.ancestors.include?(escalation))
        errors.add('project_id_escalation', 'must refer to a project which this item is part of')
      end
    else
      if (escalation)
        errors.add('project_id_escalation', 'is not possible for root projects')
      end
    end
  end

  # Validate priority code entered is valid for the type of item.
  #
  # Display an error message if the priority_code has a value and its type_name does not match the type of
  # item (e.g. StatusReport).
  def priority_code_values
    unless (priority_code && priority_code.type_name == self.class.name && priority_code.name == 'Priority')
      errors.add(:code_id_priority, "is not included in the list")
    end
  end
  
  # Validate that the status code entered is valid for the type of item.
  #
  # Display an error message if the status has a value and its type_name does not match the type of item
  # (e.g. StatusReport).
  def status_values
    unless (status && status.type_name == self.class.name)
      errors.add(:status_id, "is not included in the list") 
    end 
  end
  
  # Validate that the parent item selected is of type 'Project' and that all items that are not of type 'Project'
  # have a parent project.
  #
  # If a value for parent exists and the parent item is not of type 'Project', display an error message.
  # If a value for parent does not exist and the item is not of type 'Project', display an error message.
  def parent_type
    if parent
      errors.add("project_id", "parent must be a project") unless parent.class == Project
    else
      errors.add("project_id", "parent must be identified for all items") unless self.class == Project
    end
  end
    
end
