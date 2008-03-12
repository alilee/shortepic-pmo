require File.dirname(__FILE__) + '/../test_helper'
require 'action_item_controller'

# Re-raise errors caught by the controller.
class ActionItemController; def rescue_action(e) raise e end; end

class ActionItemControllerTest < Test::Unit::TestCase
  fixtures :codes, :statuses, :items, :action_item_details, :role_placements, :role_security_profiles, :role_details, :status_transitions
  
  def setup
    @controller = ActionItemController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @session = @request.session
    @user = Person.find(:first)
    @actionitems = ActionItem.find(:all) || []
    @session[:person] = @user
    @session[:auth_cache] = Hash.new
    @session[:project_link_cache] = Hash.new
  end

  def test_there_are_some_test_data_in_fixture
    assert_equal 2, @actionitems.size
  end
  
  def test_display_every_actionitem_in_show_view
    @actionitems.each { |i|
      get :show, { :id => i.id }
      assert_response :success
    }
  end
  
  def test_display_every_actionitem_in_edit_view
    @actionitems.each { |i|
      get :edit, { :id => i.id }
      assert_response :success
    }
  end
  
  def test_edit_and_save
    ai = @actionitems.first
    get :edit, { :id => ai.id }
    item = assigns["item"]
    assert_equal ai.description, item.description

    item.description = 'foo bar'
    post :edit, { :id => ai.id, :item => item.attributes, :detail => item.detail.attributes }
    assert_response :success
    assert_equal 'foo bar', ActionItem.find(ai.id).description
  end
  
  def test_new
    get :edit, { :project_id => Project.find(:first).id }
    assert_response :success
  end
  
  def test_list
    get :list, {}
    assert_response :success
  end
  
  def test_save_without_changing_status
    p = Person.find_by_title('Uncle person')
    assert p.current_roles.size == 1
    r = Role.find(:first,
      :include => :status,
      :conditions => ['generic_stage = ?', Status::PENDING])
    assert r.detail.security_profile_code.value == 'User'

    a = ActionItem.find(:first)
    
    assert_nil StatusTransition.find_by_type_name_and_status_id_from_and_status_id_to_and_code_id_security_profile(ActionItem.name, [0, a.status.id], [0, a.status.id], [0, r.detail.code_id_security_profile])

    @session[:person] = p
    
    get :edit, { :id => a.id }
    assert_response :success
    assert_template 'item/edit'  
    assert_select 'select#item_status_id option', 1 

    attributes = a.attributes
    detail_attrs = a.detail.attributes
    attributes['title'] = 'the new testing title'

    post :edit,  {:id => a.id, :item => attributes, :detail => detail_attrs  }
    assert_response :success
    assert_select 'td', 'Item saved'    
  end 
    
end
