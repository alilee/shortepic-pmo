require File.dirname(__FILE__) + '/../test_helper'

class ItemTest < Test::Unit::TestCase
  fixtures :items, :codes, :statuses

  # Only projects can have a null or zero project parent
  # Approach: Create new root item of each class. Error for root unless Project.  
  def test_not_null_project_parent_for_item_types_other_than_projects
    Status::VALID_TYPE_NAMES.each do |klass|
      i = klass.constantize.new 
      assert !i.valid?
      i.project_id = 0
      assert !i.valid?
      #puts i.inspect
      if i.class == Project
        assert !i.errors.full_messages.include?("Project parent must be identified for all items")
      else
        assert i.errors.full_messages.include?("Project parent must be identified for all items")
      end
    end
  end

  # Root projects have no ancestors returned by ancestor_projects
  # Children of root project with siblings have one ancestor (being the correct parent)
  # Children of root project without siblings have one ancestor (being the correct parent)
  # Grandchildren of root projects have two ancestors (being the parent and grandparent)
  # Great-grandchildren of root projects have three ancestors (being the parent, grandparent and great-grandparent)
  # Approach: walk the tree of projects to three levels and check the ancestor_projects contents
  def test_three_ancestors
    tested = false
    root_projects = Project.find_all_by_project_id(nil)
    root_projects.each do |root_project|
      assert root_project.ancestors.empty?
      root_project.children.each do |child|
        assert_equal 1, child.ancestors.size
        assert child.ancestors.include?(root_project)
        child.children.each do |grandchild|
          assert_equal 2, grandchild.ancestors.size
          assert grandchild.ancestors.include?(root_project)
          assert grandchild.ancestors.include?(child)
          grandchild.children.each do |greatgrandchild|
            assert_equal 3, greatgrandchild.ancestors.size
            assert greatgrandchild.ancestors.include?(root_project)
            assert greatgrandchild.ancestors.include?(child)
            assert greatgrandchild.ancestors.include?(grandchild)
            # test data includes enough depth
            tested = true
          end
        end
      end
    end
    assert tested
  end

  # More than one root project can be created
  def test_can_create_more_than_one_root_project
    root_projects = Project.find_all_by_project_id(nil)
    #incase fixture does not have number of root_projects > 1
    if root_projects.size < 2
      p1 = Project.new
      p1.title = "Root Project 1"
      p1.status = Status.find_by_type_name("Project")
      p1.priority_code = Code.find_by_type_name("Project")
      p1.role = Role.find(:first)
      p1.person = Person.find(:first)
      assert p1.save
      #puts p1.errors.full_messages.join("\n")
      p2 = Project.new
      p2.title = "Root Project 2"
      p2.status  = Status.find_by_type_name("Project")
      p2.priority_code = Code.find_by_type_name("Project")
      p2.role = Role.find(:first)
      p2.person = Person.find(:first)
      assert p2.save
      root_projects = Project.find_all_by_project_id(nil)
    end
    assert root_projects.size > 1
  end

  # An item cannot be escalated to a project which is not an ancestor
  # Approach: take a root project and escalate it to another root project; take an item and escalate it to alternate root
  def test_an_item_can_only_escalate_to_ancestor_projects
    rp1 = Project.find_by_title("Root orphan project")
    assert_not_nil rp1
    assert_nil rp1.parent
    rp2 = Project.find_by_title("Grandfather project")
    assert_not_nil rp2
    assert_nil rp2.parent
    rp1.escalation = rp2
    assert !rp1.valid?
    #puts rp1.errors.full_messages
    assert rp1.errors.full_messages.include?('Project id escalation is not possible for root projects')    
    i1 = Milestone.find_by_title("Father milestone")
    assert_not_nil i1
    assert_not_equal i1.parent.id, rp2.id
    assert i1.ancestor_projects.include?(rp2)
    i1.escalation = rp1
    assert !i1.valid?
    #puts i1.errors.full_messages
    assert i1.errors.full_messages.include?('Project id escalation must refer to a project which this item is part of')
  end

  # Only a root project can be escalated past the root (to nothing)
  # Approach: find some item and try to escalate it to nil
  def test_item_cant_be_escalated_to_nil
    i = Issue.find(:first)
    assert_not_nil i
    assert_not_nil i.parent
    i.escalation = nil
    assert !i.valid?
    #puts i.errors.full_messages
    assert i.errors.full_messages.include?("Project id escalation must refer to a project which this item is part of")
  end

  # Changing an item's parent causes the escalation to be reset to its
  # new parent, if the old escalation is not an ancestor of the new parent
  # Approach: Find a root project item, reset its parent to another root item, check escalated to new parent
  #  then: Find a nested item, escalate it high up in the chain, then switch projects, check no change to esc
  def test_changing_items_parents_effect_on_escalation
    rp1 = Project.find_by_title('Grandfather project')
    assert_not_nil rp1
    rp2 = Project.find_by_title('Father project')
    assert_not_nil rp2
    i = Role.find_by_project_id_and_title(rp2.id, 'Father role')
    assert_not_nil i
    #breakpoint
    i.parent = rp1
    assert i.reset_escalation_if_necessary
    i.valid?
    # puts i.errors.full_messages
    assert i.save
    assert_not_nil i.escalation
    assert_equal i.escalation.id, rp1.id
    
    p3 = Project.find_by_title('Uncle project')
    assert_not_nil p3
    assert p3.ancestors.include?(rp1)
    
    i = ActionItem.find_by_project_id(p3.id)
    assert_not_nil i
    assert i.ancestor_projects.include?(rp1)
    i.escalation = rp1
    assert i.save
    
    p4 = Project.find_by_title('Child project')
    assert_not_nil p4
    assert p4.ancestors.include?(rp1)
    
    i.parent = p4
    assert !i.reset_escalation_if_necessary
    assert_equal i.escalation, rp1
    assert_valid i
  end
  
end
