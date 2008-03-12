# TODO: C - feature to clone security profiles
class SecurityProfileController < ApplicationController

  def manage
    if request.post? then
      @new_profile = RoleSecurityProfile.new(params[:new_profile])
      @new_profile.controller_name = nil if @new_profile.controller_name == ''
      @new_profile.action = nil if @new_profile.action == '' 
      if @new_profile.save
        flash[:notice] = 'Security profile entry created successfully'
      end
    else
      @new_profile = RoleSecurityProfile.new
    end
    
    @profiles = RoleSecurityProfile.find(:all, :include => :security_profile_code, :order => 'value, controller_name, action')
    
    @page_title = 'Manage security profiles'
    render :layout => 'simple'
  end
  
end
