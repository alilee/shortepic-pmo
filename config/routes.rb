ActionController::Routing::Routes.draw do |map|
  
  # default -> summary for my main project
  map.index '', :controller => 'project', :action => 'operations'
  
  # login and logout - login controller
  map.login '/login', :controller => 'login', :action => 'login'
  map.logout '/logout', :controller => 'login', :action => 'logout'
  map.admit_one '/admit_one', :controller => 'login', :action => 'admit_one'
   
  # administrator links
  map.sql '/sql', :controller => 'application', :action => 'sql'
  map.ruby '/ruby', :controller => 'application', :action => 'ruby'
  map.code '/code', :controller => 'code', :action => 'manage'
  map.status '/status', :controller => 'status', :action => 'manage'
  map.transition '/transition', :controller => 'status', :action => 'manage_transitions'
  map.security_profile '/security_profile', :controller => 'security_profile', :action => 'manage'
  map.system_setting '/system_setting', :controller => 'system_setting', :action => 'manage'

  # search
  map.search '/search', :controller => 'application', :action => 'search'
  map.select '/select', :controller => 'application', :action => 'select'
  
  map.connect '/security_profile/edit_action', :controller => 'security_profile', :action => 'edit_action'
  
  # first-order objects will have dedicated controllers, with the name of the entity
  # all objects will have show, edit, list, delete defined for an id
  # list is the default action for a controller
  map.connect '/:controller', :action => 'list'

  # list needs no :id
  map.list '/:controller/list', :action => 'list'

  # just an id on a person gives a view of the objects assigned to that resource
  map.assignments '/person/:id/assignments', :id => /\d+/, :controller => 'person', :action => 'assignments'

  # some convenience mappings
  map.favourites '/person/:id/favourites', :id => /\d+/, :controller => 'person', :action => 'favourites'
  map.responsibilities '/person/:id/responsibilities', :id => /\d+/, :controller => 'person', :action => 'responsibilities'
  
  # just an id on a role gives a view of the objects that need my signatures
  map.signatures '/person/:id/signatures', :id => /\d+/, :controller => 'person', :action => 'signatures'
  
  # show the detail of an object
  map.show '/:controller/:id/show', :id => /\d+/, :action => 'show'

  # just an id on a project gives the summary
  map.project '/project/:id', :id => /\d+/, :controller => 'project', :action => 'operations'

  # just an id on a role gives the responsibilities
  map.role '/role/:id', :id => /\d+/, :controller => 'role', :action => 'responsibilities'

  # but for others it is to do a show
  map.connect '/:controller/:id', :id => /\d+/, :action => 'show'

  # wsdl
  map.connect '/:controller/service.wsdl', :action => 'wsdl'

  # default root is the reverse of normal:
  map.connect '/:controller/:id/:action', :id => /\d+/

  # new is edit with no :id
  map.new_item '/:controller/new/:project_id', :project_id => /\d+/, :action => 'edit'

  
end