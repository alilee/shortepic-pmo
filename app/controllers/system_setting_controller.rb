class SystemSettingController < ApplicationController
  
  def manage
    if request.post? then
      @new_setting = SystemSetting.new(params[:new_setting])
      if @new_setting.save
        flash[:notice] = 'Setting created successfully'
      end
    else
      @new_setting = SystemSetting.new
    end
    @settings = SystemSetting.find(:all, :order => 'category, name')
    
    @page_title = 'Manage system settings'
    render :layout => 'simple'
  end
  
  def edit_value
    return unless request.post? || request.xhr?
    @setting = SystemSetting.find_by_id(params[:id])
    raise params[:id] unless @setting
    old_value = @setting.value
    @setting.value = params[:value]
    if @setting.save
      render :text => @setting.value, :layout => false
    else
      render :text => old_value, :layout => false
    end      
  end
  
end
