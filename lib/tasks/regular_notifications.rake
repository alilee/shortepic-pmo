desc 'Deliver summary emails to users regarding overdue items'
task :deliver_summary_emails => :environment do 
  # For each person send a notification if they have any late objects
  
  Person.find(:all, :include => :status, :conditions => ['generic_stage in (?)', Status::in_progress]).each do |p|
    begin
      SubscriptionMailer.deliver_summary(p)
    rescue
    end
  end

end