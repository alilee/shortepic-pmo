module ComponentHelper

  # TODO: C - optimise to do one query and use classify to process
  def component_descendants_tree(component_detail)
    descendants = component_detail.children.select { |c| c.component.status.alive? }
  
    return '' if descendants.empty?
    
    result = "<ul>"
    descendants.each do |c_d|
      result << "<li>#{link_to_item c_d.component}</li>"
      result << component_descendants_tree(c_d)
    end
    result << "</ul>"

    result
  end

end