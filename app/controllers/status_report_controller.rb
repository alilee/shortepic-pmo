# This controller allows the user to create, edit and view
# status reports in the system. 
# Note: status reports can't be deleted from the system.
class StatusReportController < ItemController
  
  protected

  # Loads the required item (initially for security checking) using params[:id] and caches it for other methods.
  # This method is called by the authorisation Application before_filter.
  def load_item(id)
    @status_report = StatusReport.find(id, :include => [:detail, :status_report_lines])
  end
  
  # Default child relationships to show in tables. Override to control show view.
  #
  # Status reports can collect status for any escalated milestone.
  # TODO: B - Show completed milestones on status report (other stuff?)
  def child_collections
    [ { :table => 'milestone_status', :collection => @status_report.status_report_lines, :class => StatusReportLine, :edit => true,
      :selects => { :milestone_id => :look_escalated } } 
    ]
  end  

end
