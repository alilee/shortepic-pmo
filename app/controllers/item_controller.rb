# TODO: B - check error handling and exceptions in controller tasks, especially xhr actions.
class ItemController < ApplicationController

	include Inflector

	# Displays a list of items for a particular item type (e.g. Person, Role).
	#
	# The controller name is used to determine the type of item that needs to be returned in the find method.
	# The variables are set and used in the rendering of the list view.	 The render method is used here to specify exactly
	# where to find the view.	 This is because the URL will be different based on the type of item being listed
	# (e.g. /role/list) and the 'list' view does not exist for every type of item.
	def list
		@items = (Object.const_get singularize(camelize(controller_name))).find(:all, :order => 'title')
		@page_title = "#{humanize controller_name} list"
		render :template => '/item/list', :layout => 'simple'
	end
	
	# Displays the details about the item.
	#
	# The item id is passed through as a parameter to this method.	The variables are set and used in the
	# rendering of the show view.	 The render method is used here to specify exactly where to find the view and 
	# the layout.	 This is because the URL will be different based on the type of item being displayed
	# (e.g. /role/40) and the 'show' view does not exist for every type of item.
	def show
		@item = item_from_id
		@page_title = @item.title
		
		@all_child_collection_details = child_collections
		
		render :template => 'item/show'
	end
	
	# Displays the details about the item in edit mode so that the user can modify the item's details.
	# TODO: A - exclude the changer from favourites notification.
	def edit
	  queries.label = 'edit'

		# If the 'Show' button is selected on the Edit page, the user will be redirected to the show page for that same object.
		if params[:commit] == 'Show'
			redirect_to :action => 'show'
			return
		end
		
		# If the URL contains 'item' as the controller name, redirect the user to the correct type of item (e.g. Role)
		# based on the value selected in the 'New' select list. The controller will be item because the view lacks the 
		# sophistication to set it correctly - it is easiest to correct it here. See item/_navigation.rhtml for the problem.
		if controller_name == 'item'
			redirect_to :overwrite_params => { :controller => params[:new_object].underscore }
			return 
		end
		
		# If the item_id has been passed through as a parameter, find the existing item.	Otherwise, the item is considered
		# a new item and the item attributes defaulted.
		if item_from_id
			@page_title = @item.title
		else
			@item = (Object.const_get controller_name.camelize).new
			@item.person_id = session[:person].id
			@item.due_on = 1.day.from_now
			@item.status_id = Status.find_by_type_name_and_generic_stage(@item.class.name, Status::NIL).id
			@page_title = "#{humanize controller_name}"
			# TODO: C - check if params[project_id] is session[:person].current_project_ids.includes?(params[:project_id]) 
			@item.project_id = params[:project_id]
			@item.role_id = Project.find(params[:project_id]).role_id
		end
		@old_item = @item.clone
		@old_item.id = @item.id
		@old_item.detail = @item.detail.clone

		# Saves the item and the associated details.
		# If the item is a new item, redirect the user to the Edit page for the newly created item, otherwise
		# remain on the Edit page.
		if request.post?
		  @item.build_detail if @item.detail.nil?
			
			@item.attributes = @item.attributes.merge(params[:item] || {})
			# TODO: C - Integrate Chronic - but for all dates
			#new_due_on = Chronic.parse(params[:item][:due_on])
			#@item.due_on = new_due_on.to_date if new_due_on
		  
			@item.project_id = nil if '0' == params[:item][:project_id]
			@item.project_id_escalation = @item.project_id if '0' == params[:item][:project_id_escalation]

			@item.detail.attributes = @item.detail.attributes.merge(params[:detail] || {})
			change_errors = ActiveRecord::Errors.new(@item)
		  ItemController.validate_authority_to_change(session[:person], @item, 
		    overwritten_attrs(@old_item.attributes, @item.attributes), 
		    overwritten_attrs(@old_item.detail.attributes, @item.detail.attributes),
		    change_errors)
						
			@item.person_id_updated_by = session[:person].id

			item_was_new_record = @item.new_record?
			
			if @item.valid? && change_errors.empty?
  	    begin
    			Item.transaction do
        		@item.save!
        		@item.detail.save!
        				    
    				# shuffle in hierarchy if moved
    				@item.update_nested_sets(@old_item, item_was_new_record)
    							  
    			  # link to referrer if requested  			   
    			  Association.new(:item_id_from => @item.id, :item_id_to => params[:item_id_created_from]).save! if params[:link_to_referrer]
			  
    			  if Project == @item.class && @item.project_id.nil? && item_was_new_record 			  	
      				# If new root project then place current user in an administrator role.
      				admin_role = Role.new(
      			    :title => "#{@item.title} Administrator",
                :status_id => Status.find_by_type_name_and_enabled('Role', true, :order => 'generic_stage').id,
                :code_id_priority => Code.find_by_type_name_and_name_and_enabled('Role', 'Priority', true, :order => 'value').id,
                :role_id => 0,
                :person_id => session[:person].id,
                :person_id_updated_by => session[:person].id,
                :project_id => @item.id,
                :project_id_escalation => @item.id
      				)
				
      				security_profile_code = Code.find_by_type_name_and_name_and_value(Role.name, 'Security profile', 
                SystemSetting.system_setting('Administration', 'Administrator security profile value', 'Administrator') )
				    
      				admin_role.detail.attributes = {
                :code_id_security_profile => security_profile_code.id
              }
        
      				admin_role.save_with_validation false
      				admin_role.role_id = admin_role.id
      				admin_role.save!
    				
    				  RolePlacement.new(
                :person_id => session[:person].id,
                :role_id => admin_role.id,
                :start_on => Date.today,
                :end_on => 10.years.from_now.to_date,
                :committed_hours => 0,
                :normal_hourly_rate => 0
              ).save!
            
              @item.role_id = admin_role.id
              @item.save!
            
              session[:person].reload
              reload_project_cache()
            
              expire_fragment :controller => 'person', :action => 'static_links', :id => session[:person].id
      			end
      		end

    			flash[:notice] = "Item saved"

      	rescue Exception => e
      	  logger.warn("exception caught: #{e.message}")
      	  raise
    	  end
	    else
	      change_errors.each {|f,m| @item.errors.add(f,m) }
	    end

			if item_was_new_record && !@item.new_record?
				redirect_to :action => 'edit', :id => @item.id
				return
			end
		end

		@all_child_collection_details = @item.new_record? ? [] : child_collections
		@signatures = @item.signatures
		
		render :template => 'item/edit'
	end

	# Adds and saves a new comment against the item to the database.
	#
	# Constructs the Comment object for the Item and then saves the new comment to the database. Upon a successful
	# save the page is refreshed and the new comment displayed along with the name of the person who created the comment
	# and the date and time the comment was created.	Rendering of the view to display comments for the item is achieved
	# using the rjs template.
	#
	# TODO: C - Introduce functionality to edit and remove comments.	Should this be on the 'Show' page?	Also the data is
	# automatically committed on 'Add', there is no 'Save' option.	Could be confusing.
	# TODO: C - View to display all comments
	def add_comment
		comment = @item.comments.build( params[:comment] )
		comment.person = session[:person]
		if comment.save
			render :update do |page|
			  page.replace 'comments', :partial => 'item/comments'
				
				#page.insert_html :after, 'comment-entry', :partial => 'comment', :object => comment 
				#page.visual_effect :highlight, "comment_#{comment.id}" 
				#page << 'document.getElementById("commentsadd").value = ""'
			end
		else
		  render :nothing => true, :status => 400
		end
	end
	
	# Remove a comment, if it was created by the current user
	#
	# TODO: B - add prevention of removing a comment which is not the most recent.
	def delete_comment
	  comment = @item.comments.find_by_id(params[:comment_id], :conditions => ['person_id = ?', session[:person].id])
	  if comment.nil?
	    render :nothing => true, :status => 400
	  else
	    comment.destroy
			if request.xhr? 
			  render :update do |page|
			    page.replace 'comments', :partial => 'item/comments'
			  end
			else
			  redirect_to :back
			end
    end
	end
	
	# Adds and saves a new signature against the item to the database.	When a Signature is created for a Person
	# that is not the currently logged in Person, the Signature is defaulted to 'Unsigned'.	 When a Signature is
	# created for the Person currently logged in, the Signature record is rendered with links to 'Sign' or 
	# 'Withdraw' the Signature.	 
	#
	# Constructs the Signature object for the Item and then saves the new signature to the database.	Upon a
	# successful save the page is refreshed and the new signature record displayed. Rendering of the view to display
	# the signatures for the item is achieved using the rjs template. Request.xhr? is used to test whether the
	# incoming request was generated by an xhr object.	This allows the application to work regardless of
	# whether JavaScript is enabled.
	def add_signature
		return if request.get?

		signature = @item.signatures.build(params[:signature])
		
		if request.xhr?
			if !signature.save
				flash.now[:signature_error] = signature.errors.full_messages.join('<br/>')
			end
			@signatures = @item.signatures
			render :update do |page|
				#page.insert_html :before, 'edit-signature-line', :partial => 'item/signature_edit_line', :object => signature, :locals => { :section => :body }
				page.replace 'signatures', :partial => 'item/signature_edit_line', :locals => { :section => :table }
			end
		else
			if !signature.save
				flash[:signature_error] = signature.errors.full_messages.join('<br>')
			end
			#raise signature.inspect
			redirect_to :back
		end
	end
	
	# Removes the Signature from the item.	This functionality is only available to the Signatory that is the
	# currently logged in user.
	#
	# Checks that the person_id for the Signature is the same as the currently logged in user and the delete
	# is successfully performed.	The page is refreshed and the withdrawn signature is no longer displayed.
	def withdraw_signature
		signature = Signature.find(params[:line_id])
		if signature.person_id == session[:person].id && signature.destroy
			if request.xhr?
			  @signatures = @item.signatures
				render :update do |page|
					#page.visual_effect :fade, "signature_edit_line#{signature.id}"
  				page.replace 'signatures', :partial => 'item/signature_edit_line', :locals => { :section => :table }
				end
			end
		end
		if !request.xhr?
			redirect_to :back
		end
	end

	# Updates the Signature for the item with a signature timestamp.	This functionality is only available
	# to the Signatory that is the currently logged in user.
	#
	# Checks that the person_id for the Signature is the same as the currently logged in user and update
	# is saved successfully.	Upon a successful save the page is refreshed and the updated signature record 
	# displayed. Rendering of the view to display the updated signature for the item is achieved using the rjs template.
	def sign_signature
	  @item = Item.find(params[:id])
		signature = Signature.find(params[:signature_id])
		if signature.person_id == session[:person].id && signature.sign && signature.save
			if request.xhr?
			  @signatures = @item.signatures
				render :update do |page|
					#page.replace_html 'item-signatures', :partial => 'item/signature_show_line', :locals => { :section => :body }, :collection => @item.signatures
					page.replace 'signatures', :partial => 'item/signature_show_line', :locals => { :section => :table }
				end
			end
		end
		if !request.xhr?
			redirect_to :back
		end
	end
	
	# Adds and saves a new attachment against the item to the database recording the user and the current time.
	#
	# Constructs the Attachment object for the Item and then saves the new attachment to the database.	Upon a
	# successful save the page is refreshed and the new attachment record displayed.	The content of the file
	# itself is stored in a separate record to avoid loading it when only a listing of the available files is required.
	#
	# TODO: B - Use xhr for adding.
	def add_attachment
		@item = Item.find(params[:id])
		attachment = @item.attachments.build(params[:attachment])
		attachment.person = session[:person]
		file = params[:file_uploaded]
		attachment.uploaded_file = file
		if !attachment.save
			flash[:attachment_error] = attachment.errors.full_messages.join("<br/>")
		else
			flash[:attachment_notice] = "File uploaded successfully"
		end
		redirect_to :back
	end
	
	# Allows the user to view the file.
	#
	# Passes back to the browser information about the file's type.
	def download_attachment
		@attachment = Attachment.find_by_id(params[:attachment_id])
		if (@attachment && @attachment.item == Item.find(params[:id]))
			send_data @attachment.attachment_content.data, :filename => @attachment.filename, :type => @attachment.mime_type 
		else
			if @attachment
					flash[:attachment_error] = "You are not allowed to download the file."
			else
					flash[:attachment_error] = "File does not exist"
			end
			redirect_to :back
		end
	end
	
	# Delete an attachment.
	#
	# Finds and deletes the attachment.
	def delete_attachment
    if @item.nil?
      logger.info 'Need valid item id.'
      render_error 400, 'Need valid item id.'
      return
    end
        
    # find and destroy
    begin
      @attachment = @item.attachments.find(params[:attachment_id]).destroy
    rescue
      logger.info 'Bad placement parameters.'
      render_error 400, 'Bad placement parameters.'
      return
    end
    
    render :update do |page|
      page.visual_effect :fade, "attachment_line#{@attachment.id}"
    end
  end
	
	# Toggle the subscription status of the current user on the given item by creating or removing subscription
	# record. Only creates subscription if item is accessible.
	def subscriber
	  if params[:subscribed].nil?
	    # asking us to cancel
  	  subscription = Subscription.find_by_item_id_and_person_id(params[:id], session[:person].id)
  	  subscription.destroy unless subscription.nil?
    elsif @item
      # asking us to subscribe
  		subscription = Subscription.new(:item_id => @item.id, :person_id => session[:person].id)
      subscription.save
    end
    
    if request.xhr?
      render :nothing => true
    else
      redirect_to :back 
    end
  end
	
	# Displays a list of possible options for Linked Items based on the user entering a subset of the title
	# for the Item.
	#
	# Uses the text_field_for_auto_complete for Item (object) and Title (method) and the auto_complete_result
	# method to display a list of Items where the title partially matches the text entered.
	# TODO: B - use FTS for this search
	# TODO: A - allow selection by number
	def auto_complete_for_searchitem_title
	  project_ids = session[:person].current_project_tree_ids
		find_options = { 
			:conditions => [ "project_id in (?) and LOWER(title) LIKE ?", project_ids, '%' + params[:searchitem][:title].downcase + '%' ], 
			:order => "title ASC",
			:limit => 10 }
		@items = Item.find(:all, find_options)
		render :inline => '<%= auto_complete_result @items, \'title\' %>'
	end
		
	# Adds and saves a new assocation record against the item to the database.
	#
	# Locates the Item that is being associated using it's title.	 A newassoc object is created and
	# saved to the database.	Rendering of the view to display the associations for the item is achieved
	# using the rjs template. Request.xhr? is used to test whether the incoming request was generated by an xhr object.
	# This allows the application to work regardless of whether JavaScript is enabled.
	#
	# TODO: A - allow selection of associated items by number, like is possible for searching.
	def associate
	  
    unless params[:searchitem][:title].empty?
  		item_to = Item.find_by_title(params[:searchitem][:title])
  		Association.create(:item_id_from => @item.id, :item_id_to => item_to.id)
  		Association.create(:item_id_from => item_to.id, :item_id_to => @item.id)
  	end
		
		if !request.xhr?
			redirect_to :action => 'show', :id => params[:id]
		else
			render :update do |page|
				page.replace 'links', :partial => 'item/associations', :locals => { :item => @item }
			end
		end
	end
	
	# Removes the association from the Item.
	#
	# Locates the Item that is being disassociated using the item_id_from and item_id_to and deletes the
	# record from the database.	 The Show page is refreshed.
	def disassociate
		delassoc = Association.find_by_id_and_item_id_from(params[:association_id], @item.id)
		delassoc.destroy unless delassoc.nil?
		if !request.xhr?
		  redirect_to :action => 'show'
		else
		  render :update do |page|
		    page.replace 'links', :partial => 'item/associations', :locals => { :item => @item }
	    end
    end
	end	 
		
	# TODO: B - would be good if this showed history of detail as well.
	def history
	  @diffs = item_from_id.version_diffs
	  @page_title = item_from_id.title
		render :template => 'item/history'
  end
  
  # Show details of all linked items.
  def associated
    @associated_items = @item.associations_from.collect {|a| a.item_to }
    render :template => 'item/associated'
  end
	
	# Manage the editing functions of a standard show/edit table, rendered through a sectioned partial.
  # 
  # Calls up to the correct controller through advise_table_collection to advise the collection which is
  # holding the elements of the table. Relies on relationships between the naming of the partial and
  # the object presented in the table.
  #
  # Uses @line and @collection to interface to the rjs templates and partials.
  #
  # TODO: B - insert override ability into generic tables
  def edit_table_lines
    return unless check_xhr?
    return unless check_item?

    instructions_error = 'Bad instruction parameters.'
    child_collections.each do |c| 
      if c[:table] == params[:table]
        @child_collection_details = c
        break
      end
    end
    if @child_collection_details.nil?
      logger.info instructions_error
      render_error 400, instructions_error
      return
    end
    
    @child_collection = @child_collection_details[:collection]
    @child_class = @child_collection_details[:class]
    
    template = case params[:task]
      when 'edit': 'item/edit_table_line'
      when 'cancel': 'item/cancel_edit_table_line'
      when 'save': 'item/save_table_line'
      when 'delete': 'item/delete_table_line'
      else    
        logger.info instructions_error
        render_error 400, instructions_error
        return
    end
    
    case params[:task]
      when 'edit', 'cancel', 'delete'
        return unless find_line?
      when 'save' 
        return unless create_or_update_line?
    end
    
    if params[:task] == 'delete'
      @child_collection.delete(@line)
      @line = nil
    end
    
    @table_name = params[:table]    
    #render :template => template, :layout => false   
    # FIXME: B - reverse the rendering of entire child table instead of just our line to work around IE bug
    @table_fields = @child_collection_details[:fields] || @child_class.columns.collect {|col| col.name }
    @table_totals = @child_collection_details[:totals] || @table_fields
    @table_titles = @child_collection_details[:titles] || {}
    @table_cols = @child_collection_details[:cols] || 0
    @table_selects = @child_collection_details[:selects]
    @line = nil if params[:task] == 'cancel'
    @line = nil if params[:task] == 'save' && @line.valid?
    render :update do |page|
      # FIXME: B - put back AJAX highlighting
      page.replace "table_#{@table_name}", :partial => 'item/child_table', :locals => { :section => :just_table }
    end
  end
	
	protected
	
	# Check that the user has the authority to overwrite the given fields.
  #
  # TODO: B - check that each field change is authorised.
  def self.validate_authority_to_change(person, item, item_updates, detail_updates, errors)
    item_updates.each do |attr_name, old_value|
      case attr_name
      when 'status_id':
        logger.debug "checking that #{person.title} can change #{attr_name} from #{old_value}"
        profiles = person.current_profile_ids_over(item.project_id)
        valid = StatusTransition.find_all_valid(item.class.name, profiles, old_value).collect { |t| t.status_id_to }
        errors.add(attr_name, "cannot be changed from '#{Status.find(old_value).value}' by you") if (valid & [0,item.status_id]).empty?
      else
        # do nothing right now.
        logger.debug "(not) checking that #{person.title} can change #{attr_name} from #{old_value}"
      end  
    end 
  end
	
	# Overridden by item-specific controllers to match up a generic edit table to a collection.
  def advise_table_collection(table)
    nil
  end
	
	# Confirms that a valid item was found by the security system and is available through @item. If it isn't 
	# renders an error using Application#render_error .
	def check_item?
    return true unless @item.nil?

    msg = "Need valid #{controller_name} id."
    logger.info msg
    render_error 400, msg
    return false
  end
  
  # Find the line ensuring that it is part of the item validated by the security authorisation code. If not 
  # render an error. Return true if successful.
  def find_line?
    begin
      @line = @child_collection.find(params[:line_id])
      return true
    rescue
      logger.info 'Bad line parameters.'
      render_error 400, 'Bad line parameters.'
      return false
    end
  end

  # Create or update the line depending on whether there is an id.
  def create_or_update_line?
    begin
      line = params[:line]
      line_id = line['id'].to_i
      if 0 == line_id
        @line = @child_collection.create(line)
      else
        @line = @child_collection.find(line_id)
        @line.update_attributes(line)
      end
      return true
    rescue
      logger.info 'Bad line parameters.'
      render_error 400, 'Bad line parameters.'
      return false
    end
  end
        
  # Default child relationships to show in tables. Override to control show view.
  #
  # The required response is format is array of Hashes. Hash keys used are:
  #   :title the title for the table
  #   :collection the array of records which will be the contents of the table
  #   :edit whether to present this table on the edit screen or is just show only 
  def child_collections
    []
  end
  
  # Return a hash with the keys that are being overwritten mapped to the old values.
  def overwritten_attrs(old_attrs, new_attrs)
    old_attrs.merge(new_attrs) {|key,old_value,new_value| old_value == new_value ? nil : old_value }.delete_if {|k,v| v.nil?}
  end
  
end
