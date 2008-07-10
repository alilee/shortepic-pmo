require File.dirname(__FILE__) + '/../test_helper'
require 'milestone_controller'

# Re-raise errors caught by the controller.
class MilestoneController; def rescue_action(e) raise e end; end

class MilestoneControllerTest < Test::Unit::TestCase
  fixtures :codes, :statuses, :items, :milestone_details, :role_security_profiles, :role_details
  
  def setup
    @controller = MilestoneController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @session = @request.session
    @user = Person.find(:first)
    @milestones = Milestone.find(:all) || []
    @session[:person] = @user
    @session[:auth_cache] = Hash.new
    @session[:project_link_cache] = Hash.new
  end

  def test_show
    @milestones.each { |ms|
      get :show, { :id => ms.id }
      assert_response :success
    }
  end
  
  def test_edit
    #assumes that the milestone records exists in fixture
    @milestones.each { |milestone|
      get :edit, { :id => milestone.id }
      assert_response :success
    }  
    #On successful save, the response is a redirect to 'milestone/list'
    #On unsuccessful save, the response is template 'milestone/edit'
    #  with a div of class "errorExplanation".
    
    milestone = @milestones.first
    
    #Saving the Item without any changes
    post :edit, { :id => milestone.id, :item => milestone.attributes}
    assert_response :success
    assert_no_tag :tag => "div", :attributes => {:class => "errorExplanation"}
    
    #Saving the Item with changes (but valid change)
    post :edit, { :id => milestone.id, :item => milestone.attributes.merge({'title' => "The testing title."})}
    assert_response :success
    assert_no_tag :tag => "div", :attributes => {:class => "errorExplanation"}
    
    #Saving the Item without any title (Invalid Change)
    #must show the edit page with the errors div
    post :edit, { :id => milestone.id, :item => milestone.attributes.merge({'title' => "", 'role_id' => nil})}
    assert_response :success
    assert_template 'item/edit'
    assert_tag :tag => "div", :attributes => {:class => "errorExplanation"}
  end
  
  def test_new
    get :edit, { :project_id => 1 }
    assert_response :success
    assert_template 'item/edit'
    
    parent = Project.find(:first)
    code = Code.find_by_type_name("Milestone")
    status = Status.find_by_type_name("Milestone")
    role = Role.find(:first)
    person = Person.find(:first)
    attributes = { 'title' => 'Milestone Test 123',
                   'code_id_priority' => code.id,
                   'status_id' => status.id,
                   'project_id' => parent.id,
                   'role_id' => role.id,
                   'person_id' => person.id,
                   'project_id_escalation' => parent.id,
                   'due_on' => 3.months.from_now}
    
    #Posting Correct Data - Should Create A New Item
    post :edit,  {:project_id => parent.id, :item => attributes }
    assert_response :redirect
    
    #Posting Incorrect Data - Should Not Save Item
    post :edit,  {:project_id => parent.id, :item => {} }
    assert_response :success
    assert_template 'item/edit'
    assert_tag :tag => "div", :attributes => {:class => "errorExplanation"}
  end

  def test_list
    get :list, {}
    assert_response :success
  end
  
  def test_add_signature
      status = Status.find_by_type_name("Milestone")
      person = Person.find(:first)
      item = Milestone.find(:first)
      number_of_signatures = item.signatures.size
      @request.env["HTTP_REFERER"] = '/milestone/'+item.id.to_s+'/show'
      attributes = { 'person_id' => person.id,
                     'status_id' => status.id }
      post :add_signature, {:id => item.id, :signature => attributes}
      assert_response :redirect
      assert_equal number_of_signatures+1, item.signatures.reload.size
  end
  
  def test_sign_signature
      status = Status.find_by_type_name("Milestone")
      person = Person.find(:first)
      item = Milestone.find(:first)
      @request.env["HTTP_REFERER"] = '/milestone/'+item.id.to_s+'/show'
      signature = Signature.new( 'person_id' => person.id, 'status_id' => status.id,
                                 'item_id' => item.id )
      assert signature.save
      post :sign_signature, {:id => item.id, :signature_id => signature.id}
      assert_response :redirect
      post :show, {:id => item.id}
      assert_tag :tag => "tr", :attributes => {:id => "signature_show_line#{signature.id}"}
  end
  
  def test_withdraw_signature
      status = Status.find_by_type_name("Milestone")
      person = Person.find(:first)
      item = Milestone.find(:first)
      @request.env["HTTP_REFERER"] = '/milestone/'+item.id.to_s+'/show'
      signature = Signature.new( 'person_id' => person.id, 'status_id' => status.id,
                                 'item_id' => item.id )
      assert signature.save
      post :withdraw_signature, {:id => item.id, :line_id => signature.id}
      assert_response :redirect
      post :show, {:id => item.id}
      assert_no_tag :tag => "tr", :attributes => {:id => "signature_#{signature.id}"}
      assert !Signature.find_by_id(signature.id)
  end
  
  def test_add_signature_xhr
    milestone = Milestone.find(:first)
    get :edit, { :id => milestone.id }
    assert_response :success
    
    person = Person.find(milestone.person_id)
    status = Status.find(milestone.status_id)
    
    xhr :post, :add_signature, { :id => milestone.id, :signature => { :person_id => person.id, :status_id => status.id } }
    assert_response :success
  end
  
  def test_sign_signature_xhr
  end
  
  def test_withdraw_signature_xhr
  end
  
  def test_phase_completion
    milestone = Milestone.find_by_title('Father milestone on track')
    get :phase_completion, { :id => milestone.id }
    assert_response :success
    
    # check count for highs in 3-in progress
    # check count for meds in 3-in progress
    # check total for highs
    # check total for 3-in progress
    assert_select 'div#centrecol td.right', '1', :count => 6
    # check total for all defects
    # assert_select 'div#centrecol td.right', '2', :count => 2
  end

end
