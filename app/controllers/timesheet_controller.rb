class TimesheetController < ItemController
  
  protected
  
  # Loads the required item (initially for security checking) using params[:id] and caches it for other methods.
  # This method is called by the authorisation Application before_filter.
  def load_item(id)
    @timesheet = Timesheet.find(id, :include => [:detail, :timesheet_lines])
  end
  
  # Default child relationships to show in tables. Override to control show view.
  def child_collections
    [ { :table => 'time', :collection => @timesheet.timesheet_lines, :selects => {:milestone_id => :look_down}, :class => TimesheetLine, :show => true, :edit => true }
    ]
  end  
  
end
