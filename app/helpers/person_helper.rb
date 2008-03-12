module PersonHelper

  def select_for_roles(person)
    person.current_role_assignments.collect { |pa| [pa.role.title, pa.role.id] }
  end
    
  def view_actions
    ['show', 'edit', 'assignments', 'responsibilities', 'favourites', 'signatures', 'hierarchy', 'history']  
  end
  
  def person_descendants_tree(person)
    descendants = Person.find_all_by_person_id(person.id,
      :include => :status,
      :conditions => ['items.id <> ? and generic_stage in (?)', person.id, Status.incomplete], 
      :order => 'title'
    )
    "<ul>
       <li>#{link_to_item(person)}</li>
       #{descendants.collect {|c| person_descendants_tree(c)}.join }
     </ul>"
  end
    
end
