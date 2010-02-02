# TODO: C - display statuses in table with columns for generic_stage
class StatusController < ApplicationController

  def manage
    if request.post? then
      @new_status = Status.new(params[:new_status])
      if @new_status.save
        flash[:notice] = 'Status created successfully'
      end
    else
      @new_status = Status.new
    end
    @statuses = Status.find(:all, :order => 'type_name, sequence')
    @page_title = 'Manage statuses'
    render :layout => 'simple'
  end
  
  def edit_value
    return unless request.post? || request.xhr?
    @status = Status.find_by_id(params[:id])
    raise params[:id] unless @status
    old_value = @status.value
    @status.value = params[:value]
    if @status.save
      render :text => @status.value, :layout => false
    else
      render :text => old_value, :layout => false
    end      
  end

  def edit_sequence
    return unless request.post? || request.xhr?
    @status = Status.find_by_id(params[:id])
    raise params[:id] unless @status
    old_value = @status.sequence
    @status.sequence = params[:value]
    if @status.save
      render :text => @status.sequence, :layout => false
    else
      render :text => old_value, :layout => false
    end      
  end
  
  def manage_transitions
    if request.post? && params[:commit] != 'refresh' then
      @new_transition = StatusTransition.new(params[:new_transition])
      @new_transition.status_from = Status.find_by_type_name_and_value(@new_transition.type_name, params[:status_from])
      @new_transition.status_id_from = 0 unless @new_transition.status_from
      @new_transition.status_to = Status.find_by_type_name_and_value(@new_transition.type_name, params[:status_to])
      @new_transition.status_id_to = 0 unless @new_transition.status_to
      @new_transition.security_profile_code = Code.find_by_type_name_and_name_and_id('Role', 'Security profile', params[:new_transition][:code_id_security_profile])
      @new_transition.code_id_security_profile = 0 unless @new_transition.security_profile_code
      if @new_transition.save
        flash[:notice] = 'Transition created successfully'
      end
    else
      @new_transition = StatusTransition.new
    end
    
    type_limit = params[:type_limit]
    type_limit = nil unless Status::VALID_TYPE_NAMES.include? type_limit
    profile_limit = params[:profile_limit].nil? ? 0 : params[:profile_limit].to_i
    
    @transitions = Set.new StatusTransition.find(:all, 
      :conditions => ['((1 = ?) or (type_name = ?)) and ((1 = ?) or (code_id_security_profile = ?))', 
        type_limit == nil ? 1 : 0, type_limit || '',
        profile_limit == 0 ? 1 : 0, profile_limit],
      :order => 'type_name, status_id_from, status_id_to')
      
    @transitions = @transitions.empty? ? {} : @transitions.classify { |t| t.type_name }
      
    @profiles = Code.find_all_by_type_name_and_name('Role', 'Security profile').inject({}) {|h, c| h[c.value] = c.id; h }
    @profiles['<All>'] = 0
    
    any_status = Status.new(:value => '<Any>')
    any_status.id = 0
    @statuses_from = Set.new(Status.find(:all, :order => 'sequence')).classify {|s| s.type_name } 
    @statuses_from.each {|k,v| @statuses_from[k] = [any_status] + v.sort {|s1,s2| s1.generic_stage <=> s2.generic_stage} }

    @page_title = 'Manage Status Transitions'
    render :layout => 'simple'
  end

  protected 

  def check_auth
    logger.info "StatusController::check_auth"

    if session[:person].nil?
      redirect_to login_url
      return
    end

    error_unauthorised unless authorised?(controller_name, params[:action])
  end
    
end
