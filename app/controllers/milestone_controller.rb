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
  
  def open_defects
    defects = @milestone.detected_test_observation_details
    @open_defects = defects.find_all {|d| d.test_observation.status.incomplete? }   
  end
  
  def closed_defects
    defects = @milestone.detected_test_observation_details
    closed_defects_details = defects.find_all {|d| d.test_observation.status.generic_stage == Status::COMPLETE }
    @closed_defects = Hash.new
    closed_defects_details.each do |d|
      @closed_defects[d.root_cause_code] = (@closed_defects[d.root_cause_code] || 0) + 1
    end   
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
