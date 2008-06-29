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
    @closed_defects_root_cause = Hash.new
    @closed_defects_priority = Hash.new
    @closed_defects_severity = Hash.new
    closed_defects_details.each do |d|
      @closed_defects_root_cause[d.root_cause_code] = (@closed_defects_root_cause[d.root_cause_code] || 0) + 1
      @closed_defects_priority[d.test_observation.priority_code] = (@closed_defects_priority[d.test_observation.priority_code] || 0) + 1
      @closed_defects_severity[d.severity_code] = (@closed_defects_severity[d.severity_code] || 0) + 1
    end   
  end
  
  def defect_listing
    defect_details = @milestone.detected_test_observation_details

    buffer = String.new
    buffer << (Item.to_csv_header + ',' + TestObservationDetail.to_csv_header + "\n")
    defect_details.each do |d|
      detail_line = d.to_csv
      item_line = d.test_observation.to_csv
      buffer << (item_line + "," + detail_line + "\n")
    end
    send_data buffer, :type => 'text/csv', :filename => "defect_listing-#{Time.now.strftime('%Y%m%d%H%M')}.csv"
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
