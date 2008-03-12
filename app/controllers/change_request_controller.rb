class ChangeRequestController < ItemController
      
  protected
    
  # Loads the required item (initially for security checking) using params[:id] and caches it for other methods.
  # This method is called by the authorisation Application before_filter.
  def load_item(id)
    @change_request = ChangeRequest.find(id, :include => :detail)
  end
  
  def child_collections
    [ { :table => 'schedule', :title => 'Schedule', :collection => @change_request.date_lines, :selects => { :milestone_id => :look_down }, :class => CrDateLine, :show => true, :edit => true },
      { :table => 'effort', :title => 'Effort', :collection => @change_request.effort_lines, :selects => { :milestone_id => :look_down }, :class => CrEffortLine, :show => true, :edit => true },
      { :table => 'expenses', :collection => @change_request.expense_lines, :selects => { :milestone_id => :look_down }, :class => CrExpenseLine, :show => true, :edit => true }
    ]
  end
  
end
