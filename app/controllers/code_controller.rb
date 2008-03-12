# TODO: B - consolidated to AdminController
class CodeController < ApplicationController
    
  def manage
    if request.post? then
      @new_code = Code.new(params[:new_code])
      if @new_code.save
        flash[:notice] = 'Code created successfully'
      end
    else
      @new_code = Code.new
    end
    @codes = Code.find(:all, :order => 'type_name, name, sequence')
    
    @page_title = 'Manage codes'
    render :layout => 'simple'
  end
  
  def edit
    return unless request.post? || request.xhr?
    @code = Code.find_by_id(params[:id])
    raise params[:id] unless @code
    old_value = @code.value
    @code.value = params[:value]
    if @code.save
      render :text => @code.value, :layout => false
    else
      render :text => old_value, :layout => false
    end      
  end

  def edit_sequence
    return unless request.post? || request.xhr?
    @code = Code.find_by_id(params[:id])
    raise params[:id] unless @code
    old_value = @code.sequence
    @code.sequence = params[:value]
    if @code.save
      render :text => @code.sequence, :layout => false
    else
      render :text => old_value, :layout => false
    end      
  end

  def check_auth
    if session[:person].nil?
      redirect_to login_url
      return
    end

    error_unauthorised unless authorised?(controller_name, params[:action])
  end
  
end
