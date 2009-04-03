module ProjectHelper
  
  def view_actions
    [
      'edit', 
      'show', 
      'operations', 
      'plan',
      'issues', 
      'risks',
      #'financials', 
      'team', 
      'bookings',
      #'deliverables', 
      'library', 
      #'throughput',
      'hierarchy', 
      'roadmap',
      'defects',
      'defect_funnel',
      'defect_listing',
      'requirements',
      'requirements_burndown',
      'all',
      'dump',
      'late',
      'history']
  end
  
  # TODO: C - optimise to do one query and use classify to process
  def project_descendants_tree(project)
    descendants = project.children.select { |c| c.status.incomplete? }
    
    "<ul>
       <li>#{link_to_item project} (#{link_to_item project.role})</li>
       #{ descendants.collect {|c| project_descendants_tree(c)}.join }
     </ul>"
  end
  
  # TODO: C - optimise to do one query and use classify to process
  def requirement_descendants_tree_row(requirement_detail, effort_totals, options = {})
    depth = options[:depth] || 0
    statuses = options[:statuses] || Status.alive
    statuses = [statuses] unless statuses.is_a?(Array) 
    
    descendants = requirement_detail.children.select { |r| statuses.include?(r.requirement.status.generic_stage) }
    result = "<tr>"
    result << "<td>#{'&nbsp;&nbsp;&nbsp;' * depth}-&nbsp;#{link_to_item requirement_detail.requirement}</td>"
    result << "<td>#{requirement_detail.requirement.status}</td>"
    result << "<td>#{requirement_detail.requirement.priority_code}</td>"
    result << "<td>#{link_to_item requirement_detail.requirement.parent}</td>"
    result << "<td>#{link_to_item requirement_detail.requirement.person}</td>"
    result << "<td #{'class="overdue"' if requirement_detail.requirement.overdue?}>#{requirement_detail.requirement.due_on.to_formatted_s(date_format) if requirement_detail.requirement.due_on}</td>"
    result << "<td class='right'>#{requirement_detail.effort}</td>"
    result << "</tr>"
    effort_totals[requirement_detail.requirement.status.to_s] ||= 0
    effort_totals[requirement_detail.requirement.status.to_s] += requirement_detail.effort || 0
    
    descendants.each do |r_d|
      result << requirement_descendants_tree_row(r_d, effort_totals, options.merge(:depth => (depth+1)))
    end

    result
  end
  
end
