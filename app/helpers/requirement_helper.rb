module RequirementHelper

  # TODO: C - optimise to do one query and use classify to process
  def requirement_descendants_tree(requirement_detail)
    descendants = requirement_detail.children.select { |r| r.requirement.status.alive? }

    return '' if descendants.empty?

    result = "<ul>"
    descendants.each do |r_d|
      result << "<li>#{link_to_item r_d.requirement}</li>"
      result << requirement_descendants_tree(r_d)
    end
    result << "</ul>"

    result
  end

end
