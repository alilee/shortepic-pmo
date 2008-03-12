require File.dirname(__FILE__) + '/../test_helper'
require 'person_controller'

=begin
Instructions for Tracey:
1. Show the blank edit form for a person
  1.1 all details inputs are present
  1.2 no contact table is present
  1.3 no role assignment table is present
2. Create a new person
  2.1 contact table and inputs are present
  2.2 role assignments table and inputs are present
  2.3 flash notice is presented
3. Show a simple person
  3.1 all details inputs generated
  3.2 no contact table is present
  3.3 no role assignment table is present
4. Edit a simple person
  4.1 all details fields have inputs
  4.2 contact table and inputs are present
  4.3 role assignment table and inputs are present
5. Change simple values and save
  5.1 that changed values remain changed and are reflected in the model
  5.2 contact table and inputs are present
  5.3 role assignment table and inputs are present
  5.4 flash notice is presented
6. Add a contact
  6.1 that contact entry is reflected in model
  6.2 that invalid contact additions are reported and flagged
  6.3 that role assignment table and inputs are present
  6.4 flash notice is presented
7. Show a single contact person
  7.1 that contact fields are displayed
8. Edit a single contact person
  8.1 that contact fields are displayed with remove link
  8.2 flash notice is presented
9. Remove a single contact
  9.1 that contact fields are removed and this is reflected in model
  9.2 flash notice is presented
10. Add a second contact
  10.1 that contact fields for first contact are still displayed
  10.2 that contact entry is reflected in model
  10.3 flash notice is presented
11. Show a multi-contact person
  11.1 that contact fields are displayed for each contact
12. Remove a second contact
  12.1 contact fields for first contact are still displayed
  12.2 that contact entry is removed from model
  12.3 contact fields for removed contact are gone
  12.4 flash notice is presented
  12.5 repeat for removing first of two and second of two
13. Add 15 contacts
  13.1 fields for each contact
  13.2 fields for previous contacts are still displayed
  13.3 inputs for next are displayed
  13.4 flash notice is presented
  13.5 updated in model
14. Remove 15 contacts
  14.1 all contacts are displayed
  14.2 fields for deleted contacts are not displayed
  14.3 inputs for next are displayed
  14.4 changes reflected in model
  14.5 flash notice is presented
14. Assign to a role
  14.1 new assignment is presented
  14.2 blank inputs are presented
  14.3 flash notice is presented
  14.4 update in model
15. Error messages for details validation checks 
  15.1 errors are presented
  15.2 erroneous fields are highlighted
=end

# Re-raise errors caught by the controller.
class PersonController; def rescue_action(e) raise e end; end

# TODO: B - add tests for the child table 
class PersonControllerTest < Test::Unit::TestCase
  fixtures :codes, :statuses, :items, :person_details, :role_security_profiles, :role_details, :role_placements, :person_contacts
  
  def setup
    @controller = PersonController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @session = @request.session
    @user = Person.find_by_title('Root person', :include => :detail)
    @people = Person.find(:all, :include => :detail)
    @session[:person] = @user
    @session[:auth_cache] = Hash.new
    @session[:project_link_cache] = Hash.new
    @project = Project.find(:first)
  end

  def test_show
    @people.each { |r|
      get :show, { :id => r.id }
      assert_response :success
    }
  end
  
  def test_edit
    @people.each { |person|
      get :edit, { :id => person.id }
      assert_response :success
    }
    
    person = @people.first
      
    #On successful save, the response is a redirect to 'milestone/list'
    #On unsuccessful save, the response is template 'milestone/edit'
    #  with a div of class "errorExplanation".
    
    #Saving the Item without any changes
    post :edit, {:id => person.id, :item => person.attributes, :detail => person.detail.attributes }
    assert_response :success
    assert_no_tag :tag => "div", :attributes => {:class => "errorExplanation"}
    
    #Saving the Item with changes (but valid change)
    assert_not_equal('sp2@test.shortepic.com', person.detail.email)
    assert_not_equal('The testing title.', person.title)
    
    post :edit, { :id => person.id, 
                  :item => person.attributes.merge({'title' => "The testing title."}), 
                  :detail => person.detail.attributes.merge({'email' => 'sp2@test.shortepic.com'}) }
    assert_response :success
    assert_select 'td', 'Notice'
    assert_select 'td', 'Item saved'
    assert_select 'td.field-error', false
    assert_select 'input#item_title', true
    assert_select 'input#item_title[value="The testing title."]'
    assert_select 'input#detail_email[value="sp2@test.shortepic.com"]'

    q = Person.find(person.id, :include => :detail)
    assert_equal 'sp2@test.shortepic.com', q.detail.email
    
    #Saving the Item without any title (Invalid Change)
    #must show the edit page with the errors div
    post :edit, { :id => person.id, 
                  :item => person.attributes.merge({'title' => "", 'role_id' => nil}),
                  :detail => person.detail.attributes }
    assert_response :success
    assert_template 'item/edit'
    assert_select "div.errorExplanation", true
  end

  def test_new
    get :edit, { :project_id => @project.id }
    assert_response :success
    assert_template 'item/edit'
    
    parent = @project
    code = Code.find_by_type_name_and_name('Person', 'Priority')
    status = Status.find_by_type_name('Person')
    role = Role.find(:first)
    person = Person.find(:first)
    tzcode = Code.find_by_type_name_and_name('Person', 'Timezone')
    itemattributes = { 'title' => 'Person Test 123',
                   'code_id_priority' => code.id,
                   'status_id' => status.id,
                   'project_id' => parent.id,
                   'role_id' => role.id,
                   'person_id' => person.id,
                   'project_id_escalation' => parent.id,
                   'due_on' => 3.months.from_now }
    detailattributes = { 'email' => 'test_new@test.shortepic.com', 'code_id_timezone' => tzcode.id }
    
    #Posting correct data - should create a new item
    post :edit,  {:project_id => @project.id, :item => itemattributes, :detail => detailattributes  }
    assert_response :redirect 
    #follow_redirect
    #assert_tag :tag => 'input', :attributes => {:value => itemattributes['title']} 
    #assert_not_nil Item.find_by_title(itemattributes['title'])
    
    #Posting incorrect data - should not save item
    post :edit,  {:project_id => @project.id, :item => itemattributes.merge({ 'role_id' => 0}), :detail => detailattributes }
    assert_response :success
    assert_template 'item/edit'
    assert_tag :tag => 'div', :attributes => {:class => 'errorExplanation'}
  end

  def test_list
    get :list, {}
    assert_response :success
  end
  
  def test_assignments
    @people.each { |r|
      get :assignments, { :id => r.id }
      assert_response :success
    }
  end
  
  def test_responsibilities
    @people.each { |r|
      get :responsibilities, { :id => r.id }
      assert_response :success
    }
  end
  
  # TODO: B - Test that the favourites view returns useful information.
  def test_favourites
    @people.each { |r|
      get :favourites, {:id => r.id}
      assert_response :success
    }
  end
  
  def test_signatures
    @people.each { |r|
        get :signatures, { :id => r.id }
        assert_response :success
    }
  end
  
  def test_contacts
    person = @people.first

    contact_code = Code.find_by_type_name_and_name('Person', 'Contact')
    value = '12.3.12'
    xhr :post, :edit_table_lines, { :table => 'contacts', :task => 'save', :id => person.id, 
      :line => { :id => 0, :address => value, :code_id_contact => contact_code.id } }
    assert_response :success
    assert_not_nil PersonContact.find_by_person_id_and_code_id_contact_and_address(person.id, contact_code.id, value)

    value2 = '12.3.13'
    xhr :post, :edit_table_lines, { :table => 'contacts', :task => 'save', :id => person.id, 
      :line => { :id => 0, :address => value2, :code_id_contact => contact_code.id } }
    assert_response :success
    assert_not_nil PersonContact.find_by_person_id_and_code_id_contact_and_address(person.id, contact_code.id, value2)
  end
  
  def test_subscribing_and_cancelling
    get :show, :id => @user.id
    assert_response :success
    # FIXME: B - need to confirm that checkbox is ticked
    # assert_tag :tag => 'div', :attributes => {:id => 'subscribe'}, :descendant => 'not'
    
    # subscribe to self
    xhr :post, :subscriber, :id => @user.id, :subcribed => '1'
    assert_response :success
    
    get :show, :id => @user.id
    assert_response :success
    # assert_tag :tag => 'div', :attributes => {:id => 'subscribe'}, :descendant => 'not'
    
    # unsubscribe
    xhr :post, :subscriber, :id => @user.id
    assert_response :success

    get :show, :id => @user.id
    assert_response :success
    # assert_tag :tag => 'div', :attributes => {:id => 'subscribe'}, :descendant => 'not'
  end
  
  def test_version_diffs
    # single change
    p = Person.find(:first)
    p.title = 'test 1'
    assert p.save
    
    get :history, :id => p.id
    assert_response :success
    assert_tag :tag => 'tr', :child => 'test 1'    
    
    p.title = 'test 2'
    assert p.save
    get :history, :id => p.id
    assert_response :success
    assert_tag :tag => 'tr', :child => 'test 1'
    assert_tag :tag => 'tr', :child => 'test 2'
    
    # multiple change covered by first change
  end
  
end
