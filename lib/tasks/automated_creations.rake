# TODO: C - rake task for automated creation of documents

desc 'Generate new status reports ready for completion'
task :gen_status_reports => :environment do 
  #
  # For each project, with status report creation field
  #   Generate status report 
  #
  
  project_details = ProjectDetail.find(:all, 
    :include => {:project => :status}, 
    :conditions => ['status_report_interval > 0 and generic_stage in (?)',Status.in_progress])
  
  days_in_advance = SystemSetting.system_setting('Status reporting', 'Issue days in advance', 2)
  
  project_details.each do |pd|
    last_status_report = StatusReport.find_by_project_id(pd.project_id, 
      :include => [:detail, :status_report_lines], 
      :order => 'period_ending_on DESC')
    
    if last_status_report.nil?
      target_date = Date.today
    else
      target_date = last_status_report.detail.period_ending_on + pd.status_report_interval
      next if Date.today < (target_date - days_in_advance)
    end
    
    s = StatusReport.new
    s.title = "Status for #{pd.project.title} as at #{target_date}"
    s.project_id = pd.project_id
    s.priority_code = Code.find_by_type_name_and_name_and_enabled('StatusReport', 'Priority', true, :order => 'sequence')
    s.role_id = pd.project.role_id
    s.project_id_escalation = pd.project_id
    s.status = Status.find_by_type_name_and_enabled('StatusReport', true, :order => 'sequence')
    s.person_id = pd.project.person_id
    s.due_on = Date.today
    s.detail.period_ending_on = target_date
    if last_status_report.nil?
      s.detail.traffic_code = Code.find_by_type_name_and_name_and_enabled('StatusReport', 'Traffic', true, :order => 'sequence')
    else
      s.detail.traffic_code = last_status_report.detail.traffic_code unless last_status_report.nil?
    end
    s.person_id_updated_by = pd.project.person_id
    s.valid?
    puts s.errors.full_messages
    puts s.detail.errors.full_messages
    s.save!
    
    milestones = Milestone.find_all_by_project_id(pd.project_id, :include => :status, :conditions => ['generic_stage in (?)', Status.in_progress])
    last_status_report_lines = last_status_report.status_report_lines unless last_status_report.nil?
    milestones.each do |m|
      unless last_status_report.nil?
        last_line =  last_status_report_lines.detect {|l| l.milestone_id == m.id }
        unless last_line.nil?
          s.status_report_lines.create(last_line.attributes)
          next
        end
      end
      s.status_report_lines.create(
        :milestone_id => m.id, 
        :code_id_traffic => s.detail.code_id_traffic,
        :percent_complete => 0)
    end
  end 

end