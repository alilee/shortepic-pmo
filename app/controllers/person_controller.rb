class PersonController < ItemController

  def assignments
    @page_title = @person.title
    @assigned_items = @person.current_items
  end
  
  # TODO B - allow cancelling favourites notifications
  def favourites
    @page_title = @person.title
    @favourites = @person.favourites
  end
  
  def signatures
    @page_title = @person.title

    @signoffs_signed_but_incomplete = @person.signoffs_signed_but_incomplete
    unsigned_signatures = @person.signoffs_not_yet_signed
    
    @signoffs_ready = unsigned_signatures.select do |s|
      s.status.generic_stage < s.item.status.generic_stage ||
      (s.status.generic_stage == s.item.status.generic_stage &&
      s.status.value <= s.item.status.value)
    end
    
    @signoffs_pending = unsigned_signatures.select do |s|
      s.status.generic_stage > s.item.status.generic_stage ||
      (s.status.generic_stage == s.item.status.generic_stage &&
      s.status.value > s.item.status.value)
    end
  end

  def responsibilities
    @page_title = @person.title
    
    # find all items owned by the person logged in excluding complete
    role_ids = @person.current_role_ids
    if !role_ids.empty?
      @responsibilities = Item.find_all_by_role_id(role_ids, 
        :include => [:status, :priority_code, :person],
        :conditions => ['generic_stage in (?)', Status.incomplete], 
        :order => 'items.type, codes.sequence, statuses.value, items.due_on, items.id'
      )
    else
      @responsibilities = []
    end
  end
  
  def hierarchy
    @page_title = @person.title
  end
  
  protected
           
  # Perform a comprehensive load of the item. This method is called by the authorisation Application before_filter.
  def load_item(id)
    @person = Person.find(id, :include => :detail)
  end
  
  # TODO: B - need to limit placement data to hide the rates.
  def child_collections
    [ { :table => 'contacts', :collection => @person.contacts, :class => PersonContact, :show => true, :edit => true, :cols => 3 },
      { :table => 'current_placements', :collection => @person.current_role_placements, :class => RolePlacement, :show => true },
      { :table => 'absences', :collection => @person.absences, :class => AbsenceDetail, :show => true }
    ]
  end
  
end
