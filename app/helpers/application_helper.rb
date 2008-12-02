# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def tx(text)
    textilize text
  end  
  
  def tx_no_p(text)
    textilize_without_paragraph text
  end
    
  def system_setting(category, name, default = nil)
    SystemSetting.system_setting(category, name, default)
  end
  
  def help_link
    url = system_setting('Links', 'helpurl', 'http://wiki.shortepic.com/')
    url ? url+@controller.controller_name.camelize+@controller.action_name.camelize : '#'
  end
  
  # Abstraction for consistent icons. This can be called within link_to or link_to_remote to create clickable icons.
  # 
  # When fully implemented will return image_tags - currently returns text placeholders.
  # TODO: C - would be good to create shorthand to link icons
  def icon(name)
    case name
    when :escalated_here : image_tag 'escalated_here.gif', :size => "16x16"
    when :escalated_up : image_tag 'escalated_up.gif', :size => "16x16"
    when :delete : image_tag 'row_dump.gif', :size => "20x20", :alt => 'Delete row'
    when :edit_row : image_tag 'row_edit.gif', :size => "20x20"
    when :commit : image_tag 'row_commit.gif', :size => "20x20"
    when :cancel : image_tag 'row_cancel.gif', :size => "20x20"
    when :ticked : image_tag 'ticked.gif', :size => "20x20"
    when :toggle_hide : image_tag 'toggle.gif', :size => "20x20"
    when :person : image_tag 'person.gif', :size => "20x20"
    when :action_item : image_tag 'action_item.gif', :size => "20x20"
    when :issue : image_tag 'issue.gif', :size => "20x20"
    when :risk : image_tag 'risk.gif', :size => "20x20"
    when :milestone : image_tag 'milestone.gif', :size => "20x20"
    when :project : image_tag 'project.gif', :size => "20x20"
    when :role : image_tag 'role.gif', :size => "20x20"
    when :status_report : image_tag 'status_report.gif', :size => "20x20"
    when :change_request : image_tag 'change_request.gif', :size => "20x20"
    when :timesheet : image_tag 'timesheet.gif', :size => "20x20"
    when :meeting : image_tag 'person.gif', :size => "20x20"
    when :bullet : image_tag 'bullet.gif', :size => "20x20"
    when :requirement : image_tag 'bullet.gif', :size => '20x20'
    when :test_condition : image_tag 'bullet.gif', :size => '20x20'
    when :test_case : image_tag 'bullet.gif', :size => '20x20'
    when :test_observation : image_tag 'bullet.gif', :size => '20x20'
    when :release : image_tag 'bullet.gif', :size => '20x20'
    when :component : image_tag 'bullet.gif', :size => '20x20'
    when :absence : image_tag 'bullet.gif', :size => '20x20'
    when :sales_lead : image_tag 'bullet.gif', :size => '20x20'
    else
      #image_tag 'ico-1.gif', :size => "20x20"
      raise NotImplementedError.new(name.to_s)
    end
  end
  
  def link_to_item(item, text_override = nil, html_options = nil)
    text_override = item.title if text_override.nil?
    link_to text_override, { :controller => item.class.name.underscore, :id => item.id }, html_options
  end
  
  def link_to_show(item, options = {})
    link_to item.title, { :controller => item.class.name.downcase, :action => 'show', :id => item.id }, options
  end
  
  def link_to_action(item, action, text_override = nil, options = {})
    link_to(text_override || item.title, { :controller => item.class.name.downcase, :action => action, :id => item.id }, options)
  end

  def link_to_class(klass, text, id)
    link_to text, { :controller => klass.name.underscore, :id => id }
  end
  
  def editing?
    @controller.action_name != 'show'
  end
  
  def anchor_link(anchor_name)
    link_to("", {}, {:name => "#{anchor_name}"})
  end
  
  def link_to_anchor(name, anchor_name, options = {}, html_options = nil, *parameters_for_method_reference)
    link_to(name, options.merge({:anchor => "#{anchor_name}"}), html_options, *parameters_for_method_reference)
  end
  
  def valid_item_types
    Status::VALID_TYPE_NAMES
  end
  
  def valid_generic_stages
    Status::VALID_GENERIC
  end
  
  # Retrieve the background colour based on
  # the traffic light code.
  # - traffic_code: is a traffic code specified from the codes
  # table.
  def get_background_color(traffic_code)
    if traffic_code
      system_setting = system_setting('Traffic lights', traffic_code, '#FFFFFF')
      return system_setting
    end  
  end
  
  def select_for_tag(values)
    result = values.collect {|v| '<option>'+v+'</option>' }
  end
  
  def select_types_for_tag(options = {})
    values = Hash.new
    Status::DOMAIN_TYPES.each_pair do |group_name, klasses|
      accessible_klasses = klasses.find_all {|k| session[:person].authorised?(k.name.underscore, 'edit') }
      values[group_name] = accessible_klasses.collect {|k| [k.name, k.name.titleize.humanize] } unless accessible_klasses.empty?    
    end
    
    result = option_groups_from_collection_for_select(values, 'last', 'first', 'first', 'last')

    if options[:blank] == true
      result
    else 
      "<option value=\"0\"#{' selected="selected"' if options[:selected].nil?}> </option>" + result
    end    
  end
  
  # Return the select fields for items of this class.
  def select_for_status(klass, options = {})
    result = Status.find_all_by_type_name_and_enabled(klass.name, true, :order => 'sequence').collect {|s| [s.value, s.id]}
  end
  
  def select_values_for_status(options = {})
    result = Status.find(:all).collect {|s| s.value}
    result = result.uniq.sort
    if options[:blank] && options[:blank] == true
      result << [options[:blank_text] || '<All>', 0]
    end
  end
  
  def select_for_code(klass, name, options = {})
    result = Code.find_all_by_type_name_and_name_and_enabled(klass.name, name, true, :order => 'sequence').collect {|c| [c.value, c.id] }
    if options[:blank]
      result << [options[:blank_text] || '<Any>',0]
    end
    result
  end
    
  def view_actions
    ['show', 'edit', 'history']
  end
  
  def label_value_pair(label, value, options = {})
    row_id = "id=\"#{options[:row_id]}\"" unless options[:row_id].nil?
    row_class = "class=\"#{options[:row_class]}\"" unless options[:row_class].nil?
    row_style = "style=\"#{options[:row_style]}\"" unless options[:row_style].nil?
    field_class = "class=\"#{options[:field_class]}\"" unless options[:field_class].nil?
    "<tr #{row_id} #{row_class} #{row_style}>
      <td class=\"field-label\">#{label}</td>
      <td #{field_class}>#{value}</td>
    </tr>"
  end
  
  def authorised?(cont_name, action_name, project_id = nil)
    # in the cache?
    access_allowed = session[:auth_cache][[project_id, cont_name, action_name]]
    return access_allowed unless access_allowed.nil? 

    logger.info("full authorised check: #{cont_name}, #{action_name}, #{project_id}")
    
    session[:auth_cache][[project_id, cont_name, action_name]] = session[:person].authorised?(cont_name, action_name, project_id)
  end
  
  # TODO: C - make system and user default date formats
  def date_format
    ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS[:short]
  end

  # TODO: C - make system and user default time formats
  def time_format
    ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS[:short] 
  end
  
end
