# TODO: B - role hierarchy view
# TODO: D - message to role (similar to mailing list)
# TODO: C - view for role security audit (roles and security profile names)
class RoleController < ItemController
  
  def responsibilities
    @page_title = @role.title
    
    @responsibilities = Item.find_all_by_role_id(@role.id, 
      :include => [:status, :priority_code], 
      :conditions => ['generic_stage in (?)', Status.incomplete], 
      :order => 'type, codes.value')
  end
  
  def hierarchy
    @page_title = @role.title
  end
  
  def dump
    role_ids = @role.role_descendant_ids(Status.incomplete) << @role.id 
    @descendants = Item.find_all_by_role_id(role_ids,
      :include => [:status, :priority_code],
      :conditions => ['generic_stage in (?)', Status.incomplete],
      :order => 'type, codes.value, due_on' 
    )
  end
  
  protected
  
  # Up-call from ItemController#edit_table_lines to match a collection to an object type passed in from a table partial.  
  def advise_table_collection(table)
    case table
    when 'role_placement'
      @role.role_placements
    else 
      super(table)
    end
  end
    
  def load_item(id)
    @role = Role.find_by_id(params[:id], :include => :detail)
  end
  
  # Default child relationships to show in tables. Override to control show view.
  #
  # NOTE: role_placements is the basis of a hack in _child_table.rhtml which allows placement of anyone that can be seen by the user.
  # TODO: B - (dup) fix the role_placements-person_id select_for_visibility_to_user hack
  def child_collections
    [ { :table => 'current_placements', :collection => @role.current_role_placements, :class => RolePlacement, :show => true,
        :fields => [:person_id, :start_on, :end_on, :committed_hours, :normal_hourly_rate, :overtime_hourly_rate],
        :totals => [:committed_hours],
        :titles => {:committed_hours => 'Commitment', :normal_hourly_rate => 'Normal rate', :overtime_hourly_rate => 'O/t rate'} 
      }, 
      { :table => 'role_placements', :collection => @role.role_placements, :class => RolePlacement, :edit => true, 
        :fields => [:person_id, :start_on, :end_on, :committed_hours, :normal_hourly_rate, :overtime_hourly_rate],
        :selects => { :person_id => :look_any }, 
        :totals => [:committed_hours],
        :titles => {:committed_hours => 'Commitment', :normal_hourly_rate => 'Normal rate', :overtime_hourly_rate => 'O/t rate'} 
      } 
    ]
  end  
  
end
