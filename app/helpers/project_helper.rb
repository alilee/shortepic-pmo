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
  
end
