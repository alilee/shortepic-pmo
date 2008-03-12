class SubscriptionMailer < ActionMailer::Base

  def user_notification(recipients, item, sent_at = Time.now)
    @subject = "#{$email_subject_prefix} #{item.class.name.titleize.humanize} updated - #{item.title}"
    @body = { 'item' => item }
    @recipients = recipients
    @from       = $email_from_address
    @sent_on    = sent_at
  end
  
  # Mail the user their new password, including a link to the site.
  def inform_password(recipient, password)
    @subject = "#{$email_subject_prefix} Access to PMO on #{$hostname}"
    @body = { 'password' => password }
    @recipients = recipient
    @from = $email_from_address
  end
  
  # Notify the administrator that a scheduled job has run
  def notify_admin(recipient, job_name, further_info = nil)
    @subject = "#{$email_subject_prefix} Scheduled job #{job_name} complete on #{$hostname}"
    @recipients = recipient
    @from = $email_from_address
    @body = { 'info' => further_info }
  end
  
  # Notify a user of their situation and specifically their overdue items
  #
  # TODO: C - clean this up to use a few queries for all people rather than a few for each
  def summary(recipient)
    @subject = "#{$email_subject_prefix} Summary for #{Date.today}"
    @recipients = recipient.detail.email
    @from = $email_from_address
    
    overdue_assignments = Item.count(:include => :status, 
      :conditions => ['person_id = ? and generic_stage in (?) and due_on < ?', recipient.id, Status::incomplete, Date.today])
    total_assignments =   Item.count(:include => :status, 
      :conditions => ['person_id = ? and generic_stage in (?)', recipient.id, Status::incomplete])
    
    overdue_responsibilities = Item.count(:include => :status, 
      :conditions => ['role_id in (?) and generic_stage in (?) and due_on < ?', recipient.current_role_ids, Status::incomplete, Date.today])
    total_responsibilities = Item.count(:include => :status, 
      :conditions => ['role_id in (?) and generic_stage in (?)', recipient.current_role_ids, Status::incomplete])
    
    ready_to_sign = Signature.count(:include => :item,
      :conditions => ['signatures.person_id = ? and signed_at is null and signatures.status_id = items.status_id',recipient.id])
      
    assigned_projects = Project.find(:all, 
      :include => :status, 
      :conditions => ['person_id = ? and generic_stage in (?)', recipient.id, Status::incomplete])
    
    @body = { 
      'recipient' => recipient,
      'overdue_assignments' => overdue_assignments, 
      'total_assignments' => total_assignments,
      'overdue_responsibilities' => overdue_responsibilities, 
      'total_responsibilities' => total_responsibilities,
      'ready_to_sign' => ready_to_sign,
      'assigned_projects' => assigned_projects
    }
  end
  
end
