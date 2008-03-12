module RoleHelper

  def view_actions
    ['show', 'edit', 'responsibilities', 'hierarchy', 'dump', 'history']  
  end
  
  # TODO: B - show names of placed Persons
  def role_descendants_tree(role)
    descendants = Role.find_all_by_role_id(role.id, 
      :include => :status,
      :conditions => ['items.id <> ? and generic_stage in (?)', role.id, Status.incomplete], 
      :order => 'title'
    )
    "<ul class=\"role\">
       <li>#{link_to_item(role)} (#{role.detail.security_profile_code.value}, #{role.current_role_placements.size})
         #{placement_list role.current_role_placements unless role.current_role_placements.empty?}
       </li>
       #{ descendants.collect {|c| role_descendants_tree(c)}.join }
     </ul>"
  end
  
  def placement_list(placements)
    result = '<ul class="person">'
    placements.each do |p|
      result << "<li> #{link_to_item p.person} </li>"
    end
    result << '</ul>'
    result
  end
  
end