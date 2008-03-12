module StatusReportHelper
  
  # Retrieve the milestones for the given
  # project id.
  def depr_get_project_milestones(project_id)
    Project.find(project_id).milestones
  end
  
  # Retrieve the status report lines for
  # the given item, adding extra lines for the 
  # milestones that were'nt given a status
  # report line.
  def depr_get_status_report_lines(status_report)
    status_report_lines = status_report.statusreport_lines
    line_milestone_ids = status_report_lines.collect do |line| line.milestone_id end
    milestones = Project.find(status_report.project_id).milestones
    milestones.each do |milestone|
      if !line_milestone_ids.include?(milestone.id)
        line = StatusreportLine.new
        line.milestone = milestone
        line.traffic_code = nil
        status_report_lines << line
      end
    end
    status_report_lines
  end
  
  def select_for_traffic
    traffic_codes = Code.find_all_by_type_name_and_name('StatusReport', 'Traffic')
    traffic_codes.collect {|code| [code.value, code.id] }
  end
  
  def select_for_project_milestone(project)
    project.children_by_class(Milestone).collect{|m| [m.title, m.id]}
  end
  
  def milestone_table_headings
    '<tr><th>Milestone</th><th>Traffic light</th><th>Percent complete</th><th>Hours to complete</th><th>Complete date</th><th>&nbsp;</th></tr>'
  end

end
