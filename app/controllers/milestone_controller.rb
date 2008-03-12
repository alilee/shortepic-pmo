class MilestoneController < ItemController
  
  def financials
    # baseline time
    @baseline_effort_lines = CrEffortLine.find_all_by_milestone_id(@milestone.id, :include => [:role, {:change_request => :status}],
      :conditions => ['generic_stage = ?', Status::COMPLETE])
    
    # actual time
    @actual_effort_lines = TimesheetLine.find_all_by_milestone_id(@milestone.id, :include => [:role, {:timesheet => :status}],
      :conditions => ['generic_stage = ?', Status::COMPLETE])

    # baseline expenses
    # actual expenses
    
    @roles = @baseline_effort_lines.collect {|el| el.role }
  end
  
  protected
  
  # Loads the required item (initially for security checking) using params[:id] and caches it for other methods.
  # This method is called by the authorisation Application before_filter.
  def load_item(id)
    @milestone = Milestone.find(id, :include => :detail)
  end
  
  # TODO: B - need to limit placement data to hide the rates.
  def child_collections
    [ { :table => 'milestone_dependencies', :collection => @milestone.predecessor_dependencies, :class => MilestoneDependency, :show => true, :edit => true,
        :fields => [:milestone_id_predecessor, :code_id_dependency_type, :is_critical], 
        :selects => { :milestone_id_predecessor => :look_any },
        :titles => {:code_id_dependency_type => 'Type'}
      }
    ]
  end
  
  
end
