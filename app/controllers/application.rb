require 'pp'
require 'csv'

# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods and models added will be available for all controllers.
# TODO: C - need to create admin controller
class ApplicationController < ActionController::Base

  include ExceptionNotifiable
  include QueryStats

  # The before_filter method intercepts all calls to the actions in all controllers. In this
  # case the check_auth method will be run.
  before_filter :check_auth

  #prepend_before_filter :localize

  # For Calendar Helper
  #def localize
  #  # determine locale and set other relevant stuff
  #  ActiveRecord::Base.date_format = date_format
  #end

  # FIXME: C - will not search root projects because have nil project_id
  # TODO: C - Automatically redirect if single result to search.
  def search
    @query = params[:search_text] || ''
    if @query.blank?
      redirect_to :action => 'select'
      return
    end
      
    if @query.to_i.to_s == @query
      @results = Item.find_all_by_id(@query.to_i)
    else
      begin
        @results = Item.find(:all, 
          :include => :status, 
          :conditions => ['project_id in (?) and generic_stage in (?) and res_idx_fti @@ to_tsquery(?)', 
            session[:person].current_project_tree_ids, 
            Status.alive,
            @query],
          :order => "rank(res_idx_fti, to_tsquery('#{@query}'))")
      rescue
        flash[:error] = 'Search text should be words separated by | (for logical OR) or & (for logical AND).'
      end
    end
    
    if @results && @results.size == 1
      item = @results.first
      redirect_to :controller => item.class.name.underscore, :action => 'show', :id => item.id
    else
      @page_title = 'Full text search'
      render :template => 'search', :layout => 'simple'
    end
  end
  
  # Structured search
  def select
    if params.size > 2
      conditions = Array.new
      unless params[:status].nil?
        conditions << "(statuses.value in (#{params[:status].collect {|v| "'#{v}'"}.join(',')}))"
      end
      unless params[:assigned_to].nil?
        conditions << "(person_id in (#{params[:assigned_to].join(',')}))"
      end
      unless params[:i][:due_on].empty?
        due_on_ops = {'-1' => '<', '0' => '=', '1' => '>'}
        due_on = Date.parse(params[:i][:due_on])
        conditions << "(due_on #{due_on_ops[params[:due_on_op]]} #{due_on.to_formatted_s(:db)})"
      end
      unless params[:project_id].nil?
        project_ids_down = []
        project_ids_up = []
        params[:project_id].each do |project_id|
          project_ids_down << project_id
          project = Project.find(project_id)
          project_ids_down.concat(project.descendant_project_ids)
          if params[:project_id_op] == '0' # escalated
            project_ids_up << project_id
            project_ids_up.concat(project.ancestor_ids)
          end
        end
        conditions << "(project_id in (#{project_ids_down.join(',')}))"
        if params[:project_id_op] == '0' # Escalated to
          conditions << "(project_id_escalation in (#{project_ids_up.join(',')}))"
        end
      end
      unless params[:role_id].nil?
        if params[:role_id_op] == '0' # direct
          conditions << "(role_id in (#{params[:role_id].join(',')}))"
        else
          role_ids_down = []
          params[:role_id].each do |id|
            role_ids_down << id.to_i
            role = Role.find(id)
            role_ids_down.concat(role.descendant_role_ids)
          end
          conditions << "(role_id in (#{role_ids_down.uniq.join(',')}))"
        end
      end
      unless params[:priority].nil?
        conditions << "(codes.value in (#{params[:priority].collect {|v| "'#{v}'"}.join(',')}))"
      end           
      unless params[:type].nil?
        conditions << "(type in (#{params[:type].collect {|t| "'#{t}'"}.join(',')}))"
      end
        
      @conditions = conditions.join(' AND ')
      conditions << "(project_id in (#{session[:person].current_project_tree_ids.join(',')}))"
      @results = Item.find(:all, :include => [:status, :priority_code], :conditions => conditions.join(' AND ')) 
    end
    
    @statuses = Status.find(:all).collect {|s| s.value }.uniq.sort
    @people = Person.find(:all)
    @projects = Project.find(:all, :order => 'lft')
    @priorities = Code.find_all_by_name('Priority').collect {|c| c.value}.uniq.sort
    @roles = Role.find(:all)

    @page_title = 'Structured search'
    render :template => 'select', :layout => 'simple'
  end

  # Provides a user interface to be able to enter a SQL query and have the results returned in a
  # user-friendly format. No validation or protection is performed and is, therefore, very insecure.
  #
  # Passes the SQL query text through to a direct connection to the database.
  def sql
    @sql = params[:sql]
    if request.post?
      begin
        @sqlresult = Item.connection.select_all(@sql)
      rescue ActiveRecord::StatementInvalid => e
        flash[:error] = e.message
      end
    end
    
    @page_title = 'Interactive SQL'

    if @sqlresult && params[:result_format] == 'csv'
      buffer = String.new
      CSV::Writer.generate(buffer) do |csv|
        csv << @sqlresult.first.keys unless @sqlresult.empty?
        @sqlresult.each do |r|
          csv << r.values
        end
        csv << [@sql]
      end
      send_data buffer, :type => 'text/csv', :filename => "query_result-#{Time.now.strftime('%m%d%H%M%S')}.csv"
    else
      render :template => 'sql', :layout => 'simple'
    end
  end

  # Provides a user interface to be able to enter Ruby code and have the results returned in a
  # user-friendly format. No validation or protection is performed and is, therefore, very insecure.
  #
  # Evaluates the Ruby expression passed using the eval standard library function and pretty prints the result.  
  def ruby
    @ruby = params[:ruby]
    if request.post?
      evalresult = nil
      begin
        evalresult = eval(@ruby)
        @rubyresult = PP.pp(evalresult, "")
      rescue Exception => e
        flash[:error] = e.inspect
      end
    end
    
    @page_title = 'Interactive Ruby'
    render :template => 'ruby', :layout => 'simple'
  end
  
  protected
  
  def render_error(status, message = ' ')
    render :text => message, :status => status
  end
  
  # Display error when requests unauthorised project/controller/action.
  #
  # Displays error page and logs attempted access.
  # TODO: C - log and notify attempts at unauthorised access.
  # TODO: B - create meaningful error page which directs user to adminstrator if further access is 
  # warranted.
  def error_unauthorised
    @page_title = 'Unauthorised view'
    @project_id = session[:person].project_id
    
    render :status => 401, :template => 'unauthorised', :layout => 'simple'
  end

  # Redirect the user to the login view if they have not yet logged in. If they have logged in, and 
  # are seeking access to a specific item, check the users rights to access the requested function
  # for the given object, if any.
  #
  # Checks for the existance of the Person object in the session.  If the Person object does not exist
  # display the login view. Otherwise, check the authorisation and if the request is unauthorised, 
  # redirect to the unauthorised page.
  #
  # FIXME: C - deal with exceptions raised (in item_from_id for example)
  def check_auth #:doc:
    if session[:person].nil?
      redirect_to login_url
      return
    end 
    
    # if route includes :id of an item, capture the project of this item for authorisation
    # if the item itself is a project, then we don't need a role in the parent, just in that project
    item = item_from_id
    if item.nil?
      @project_id = nil
    elsif item.class == Project
      @project_id = item.id
    else
      @project_id = item.project_id
    end
    
    error_unauthorised unless authorised?(controller_name, params[:action], @project_id)
  end
  
  # Load the given item to allow security checking.
  #
  # Override in derived classes to customise the load (eg for :includes) and create additional access variables.
  def load_item(id)
    Item.find(id)
  end
  
  # Caches the loading of an item passed in through params[:id]. Uses a down-call to load_item to tailor
  #
  # Item is cached in a class attribute named @item_from_id.
  def item_from_id
    return @item_from_id if defined?(@item_from_id) && @item_from_id && @item_from_id.id == params[:id]
    if params[:id].nil?
      @item_from_id = nil 
    else
      @item_from_id = load_item(params[:id])
      @item = @item_from_id
    end
    return @item_from_id
  end

  # Determine if the current user is authorised to access the given function. Access to an item 
  # is defined as matching the controller_name and action for any role which is in an ancestor 
  # project of the requested item.
  # 
  # Rather than walking the placements, roles, ancestors and security profiles on each request,
  # authorised combinations of projects, controller_names and actions are cached in the session.
  # This cache is assumed to have been created for any user, even if empty. This is handled on 
  # each login.
  def authorised?(cont_name, action, project_id = nil)
    # in the cache?
    access_allowed = session[:auth_cache][[project_id, cont_name, action]]
    return access_allowed unless access_allowed.nil?

    logger.info("full authorised check: #{cont_name}, #{action}, #{project_id}")
    
    session[:auth_cache][[project_id, cont_name, action]] = session[:person].authorised?(cont_name, action, project_id) 
  end
  
  # Checks whether the call to this routine was via XmlHttpRequest. If not, calls Application#render_error.
  # FIXME: C - sometimes this fails - possibly a bug in the JavaScript handling, or possibly not
  def check_xhr?
    #if !request.xhr?
    #  logger.info 'Requires JavaScript browser with XMLHTTPRequest capability.'
    #  render_error 400, 'Requires JavaScript browser with XMLHTTPRequest capability.'
    #  return
    #end
    return true
  end
  
  # Reloads the project link cache with current assigned projects and favourites
  def reload_project_cache
    project_names = session[:person].current_projects.collect do |p|
      { :id => p.id, :title => p.title }
    end
    project_names.concat session[:person].favourite_projects.collect do |p|
      { :id => p.id, :title => p.title }
    end
    session[:project_link_cache] = project_names.uniq
  end
  
  def system_setting(category, name, default = nil)
    SystemSetting.system_setting(category, name, default)
  end
    
end
