# == Schema Information
# Schema version: 12
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
#  res_idx_fti           :tsvector      
#

# Represents a record in the +items+ table where <tt>type = 'Person'</tt>. It links the 
# specific fields for the Person.
#
# Uses single table inheritance from the +items+ table and links to a PersonDetail through 
# a has_one relationship. Each time a new Person is created, the details record is
# created and associated automatically.
class Person < Item
  has_one :detail, :class_name => 'PersonDetail'
  
  has_many :items

  has_many :contacts, :class_name => 'PersonContact', :include => :contact_code, :dependent => :destroy

  has_many :role_placements, :include => {:role => :parent}, :dependent => :destroy
  has_many :current_role_placements, :class_name => 'RolePlacement', :include => :role, 
    :conditions => 'now() between start_on and end_on'

  has_many :signoffs, :class_name => 'Signature', :include => :item, :dependent => :destroy
  #has_many :signoffs_ready, :class_name => 'Signature', :include => :item,
    #:conditions => 'signed_at is null and items.status_id = signatures.status_id'
  #has_many :signoffs_pending, :class_name => 'Signature', :include => :item,
    #:conditions => 'signed_at is null and items.status_id <> signatures.status_id'

  has_many :favourites, :class_name => 'Subscription', :include => :item, :dependent => :destroy
   
  has_many :absences, :class_name => 'AbsenceDetail', :include => :absence  
   
  # Is password too weak?
  def self.weak_password(password_candidate)
    return password_candidate.length < 3
  end
  
  # Hash password with given salt for comparison against stored password. Password and salt are expected to be 
  # strings and the routine returns a string.
  # 
  # Storing the hashed password means that it can't be learnt by someone browsing the database. The salt makes it
  # harder to conduct a dictionary attack using a dictionary of pre-hashed words. An attacker now has to generate
  # and store a hashed dictionary for each possible salt value. 
  def self.hash_password(password, salt)
    Digest::SHA256.hexdigest(salt+password)
  end

  # Set the password for the given person.
  #
  # Delegates to PersonDetail.
  def set_password(new_password)
    detail.set_password(new_password)
  end
  
  # Reset the password for this user to something random. Emails notification, and
  # informs user of URL for application.
  #
  # Delegates to PersonDetail.
  def reset_password
    detail.reset_password()
  end
  
  # Timesheets for this person using timesheet_details.person_id_worker
  def timesheets
    Timesheet.find(:all, :include => :detail, 
      :conditions => ['person_id_worker = ?', id])
  end
  
  # Timesheet lines for this person using timesheet_details.person_id_worker
  def timesheet_lines
    TimesheetLine.find(:all, :include => [:timesheet => :detail], 
      :conditions => ['person_id_worker = ?', id])
  end

  # Items assigned to this person which are not yet complete.
  def current_items
    Item.find_all_by_person_id(id, :include => [:status, :priority_code], 
      :conditions => ['generic_stage in (?)', Status.incomplete], 
      :order => 'type, codes.value')
  end
  
  # Return the person's current roles.
  #
  # The person object only has one role, however a person can be assigned to one or many roles over the duration
  # of the project.  This method includes the +role_placements+ table in the query and only returns assignments
  # where the current system date falls between the start and end dates of the assignment.
  def current_roles
    current_role_placements.collect {|p| p.role }
  end
  
  # Return the role_id's for the person's current roles.
  #
  # Where the current_roles array is not empty, return the id for the role for each element in the current_roles array.
  def current_role_ids
    current_role_placements.collect {|p| p.role_id }
  end
  
  # Return the projects in which the person has current roles.
  def current_projects
    role_projects = current_roles.collect {|r| Project.find(r.project_id) }
    role_projects.uniq.sort {|x,y| x.lft <=> y.lft }
  end 
  
  # Return the project_ids in which the person has current roles.
  def current_project_ids
    role_project_ids = current_roles.collect {|r| r.project_id }
    # could have more than one role in a single project
    role_project_ids.uniq 
  end
  
  # Return the project_ids in or above which the person has current roles.
  def current_project_tree_ids
    (current_project_ids + current_projects.inject([]) {|ids, p| ids + p.descendant_project_ids }).uniq
  end
  
  # Return the security_profiles_roles governing a given project
  def current_profile_ids_over(governed_project_id)
    if governed_project_id.nil?
      result = Code.find_by_type_name_and_name_and_value(Role.name, 'Security profile', 
        SystemSetting.system_setting('Administration', 'Administrator security profile value', 'Administrator') )
			[result.id]
    else
      result = current_roles.collect {|r| r.parent.self_and_descendant_project_ids.include?(governed_project_id) ? r.detail.code_id_security_profile : nil }
      result.compact
    end
  end
  
  # Items which are Projects and favourites of this user
  def favourite_projects
    Project.find(:all,
      :include => :subscriptions,
      :conditions => ['subscriptions.person_id = ?', self.id],
      :order => 'lft'
    )
  end
  
  # Return the items for the Person that have not yet been signed and are incomplete.
  #
  # Finds all the +signature+ records for the Person where they have not yet been 'signed' and where the associated
  # +item+ record has a status that is incomplete. 
  def signoffs_signed_but_incomplete
    Signature.find(:all, :include => {:item => :status}, 
      :conditions => ['signatures.person_id = ? and 
        signed_at is not null and 
        generic_stage in (?)', id, Status.incomplete])
  end
  
  # FIXME: C - this includes ones that are ready but have passed
  def signoffs_not_yet_signed
    Signature.find_all_by_person_id(id, :include => [{:item => :status} , :status], :conditions => 'signed_at is null')
  end

  # Determine if the user is authorised to access the given function. Access to an item 
  # is defined as matching the controller_name and action for any role which is in an ancestor 
  # project of the requested item.
  def authorised?(cont_name, action_name, within_project_id = nil)
    current_roles.each do |r|
      next unless within_project_id.nil? || within_project_id == r.project_id || Project.find(r.project_id).descendant_project_ids.include?(within_project_id)

      # matching profile entry for role above this item
      return true if RoleSecurityProfile.profile_matches?(r.detail.code_id_security_profile, cont_name, action_name)
    end
    return false
  end
  
  # Pretty email address
  def full_email
    "#{self.title} <#{self.detail.email}>"
  end
  
end
