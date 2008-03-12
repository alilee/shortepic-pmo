require File.dirname(__FILE__) + '/../test_helper'

class RoutesTest < Test::Unit::TestCase
  def setup
  end

  # TODO: B - add test for role/3
  def test_routes
    assert_routing '', {:controller => 'project', :action => 'operations'}
    # FIXME: A - why doesn't this test correctly?
    # assert_routing '/project/10', {:controller => 'project', :action => 'operations', :id => '10'}
    assert_recognizes({:controller => 'project', :action => 'list'}, '/project')
    assert_recognizes({:controller => 'project', :action => 'show', :id => '10'}, '/project/10/show')
    assert_recognizes({:controller => 'project', :action => 'edit', :project_id => '0'}, '/project/new/0')
    assert_recognizes({:controller => 'issue', :action => 'show', :id => '13'}, '/issue/13')
    assert_recognizes({:controller => 'issue', :action => 'show', :id => '13'}, '/issue/13/show')
    assert_routing '/issue/13/edit', {:controller => 'issue', :action => 'edit', :id => '13'}
    assert_routing '/issue/13/list', {:controller => 'issue', :action => 'list', :id => '13'}
    assert_routing '/issue', {:controller => 'issue', :action => 'list'}
    assert_routing '/issue/new/3', {:controller => 'issue', :action => 'edit', :project_id => '3'}
    assert_recognizes({:controller => 'issue', :action => 'list'}, '/issue/list') 
    assert_routing '/action_item/13/edit', {:controller => 'action_item', :action => 'edit', :id => '13'}
    assert_routing '/action_item/13/list', {:controller => 'action_item', :action => 'list', :id => '13'}
    assert_routing '/action_item', {:controller => 'action_item', :action => 'list'}
    assert_routing '/action_item/new/3', {:controller => 'action_item', :action => 'edit', :project_id => '3'}
    assert_recognizes({:controller => 'action_item', :action => 'list'}, '/action_item/list') 
    assert_routing '/person/45/assignments', {:controller => 'person', :action => 'assignments', :id => '45'}
    assert_routing '/person/45/responsibilities', {:controller => 'person', :action => 'responsibilities', :id => '45'}
    assert_recognizes({:controller => 'person', :action => 'list'}, '/person/list') 
    assert_routing '/person', {:controller => 'person', :action => 'list'}
    assert_routing '/login', {:controller => 'login', :action => 'login'}
    assert_routing '/logout', {:controller => 'login', :action => 'logout'}
  end
end
