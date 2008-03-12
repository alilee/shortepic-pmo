require File.dirname(__FILE__) + '/../test_helper'

=begin

Escalation:
11. Changing the parent of a project, resets the escalation to the changed project IF the old escalation is not now an ancestor.
    This has been tested in item_test.rb: test_changing_items_parents_effect_on_escalation
12. Escalated items are those which are escalated to this project OR escalated to this project's ancestors.
    Is this a test of the method escalated_issues?
13. Associated items are those items which are associated either to OR from this project
    Is this a test of the method associated_issues?
14. Descendant issues are those issues which are children of this project or a descendant of this project
    Is this a test of the method descendent_issues?
    
=end

class ProjectTest < Test::Unit::TestCase
  fixtures :items

  # Simple test for addition of 1 valid record.
  def test_add_valid
    p = Project.new
    p.title = 'Test project'
    p.role = Role.find(:first)
    p.person = Person.find(:first)
    p.status = Status.find_by_type_name("Project")
    p.priority_code = Code.find_by_type_name_and_name("Project", "Priority")
    p.updated_by = p.person
    assert_valid p.detail
    assert_valid p
    assert p.save
    p1 = Project.find_by_title('Test project')
    assert_not_nil p1
    p_detail1 = ProjectDetail.find_by_project_id(p1.id)
    assert_not_nil p_detail1
  end
  
  # Test that an invalid discount rate cannot be entered.
  def test_valid_discount_rate
    p = Project.new
    p.title = 'Test project'
    p.role = Role.find(:first)
    p.person = Person.find(:first)
    p.status = Status.find_by_type_name("Project")
    p.priority_code = Code.find_by_type_name_and_name("Project", "Priority")
    p.updated_by = p.person
    p.detail.discount_rate = -1
    assert !p.detail.valid?
    assert_equal "should be between 0 and 100", p.detail.errors.on(:discount_rate)
    p.detail.discount_rate = 0
    assert p.save
  end  
  
  # Test that a project cannot become a child of one of its children
  # Approach: Take a root- and non-root-project with a child and assign the child to be its parent.
  def test_a_project_cannot_become_a_child_of_its_children
    rp1 = Project.find_by_title('Grandfather project')
    assert_not_nil rp1
    assert_nil rp1.parent
    p2 = Project.find_by_title('Father project')
    assert_not_nil p2
    assert p2.ancestors.include?(rp1)
    rp1.parent = p2
    assert !rp1.valid?
    assert rp1.errors.full_messages.include?('Project cannot be a child of one of its descendants')
  end

  # Test that the correct ancestors are returned in the ancestor_ids method.
  # TODO: C - test for condition where uncle is not counted
  def test_ancestors_for_a_project
    root_tested = false
    child_tested = false
    grandchild_tested = false
    uncle_tested = false
    sibling_tested = false
    all_projects = Project.find(:all)
    all_projects.each do |p|
      my_ancestors = p.ancestors # trust this library routine
      root_tested = true if my_ancestors.empty? 
      child_tested = true if (my_ancestors.size == 1)
      grandchild_tested = true if (my_ancestors.size == 2)
      sibling_tested = true if (Project.find_all_by_project_id(p.project_id).size > 1)
      project_ids = p.ancestor_ids # routine under test
      assert_equal my_ancestors.size, project_ids.size
      my_ancestors.each do |a|
        assert project_ids.include?(a.id)
      end      
    end    
    assert root_tested
    assert child_tested
    assert grandchild_tested
    # assert uncle_tested
    assert sibling_tested
  end
  
  # Test ancestor_of? method
  
  # Test that a project with no items with the project as their parent has no descendants.
  def test_children_for_a_project
    no_child_tested = false
    children_tested = false
    all_projects = Project.find(:all)
    all_projects.each do |p|
      my_children = p.children_by_class(Person)
      no_child_tested = true if my_children.empty?
      children_tested = true if !my_children.empty?
      items = p.children_by_class(Person)
      item_ids = p.children_ids_by_class(Person)
      assert_equal my_children.size, items.size
      assert_equal my_children.size, item_ids.size
      my_children.each do |c|
        assert item_ids.include?(c.id)
      end
    end
    assert no_child_tested
    assert children_tested
  end
  
  # Test that a project with a single child project has one descendant_project.
  def test_one_descendant_for_a_project
    p = Project.find_by_title("Child project")
    assert_not_nil p
    p_children = p.children_by_class(Project)
    assert_equal p_children.size, 1
    assert_equal p.descendant_projects.size, p_children.size
  end
  
  # Test that a project with a single child project and a single grandchild project has two descendant_projects.
  
  # Test that a project with two child projects has two descendant_projects.
  
  # Test that a project with a single child, grandchild, and great-grandchild has three descendant_projects.
  
  # Test that a project with a single child, two grandchildren, and a great-grandchild has four descendant_projects
  
  # Test that project with two children, who each have two children, who each have two children, has fourteen descendant_projects
  
  # Test that the escalation point of a direct child object is null.
  
  # Test that the escalation point of a grandchild object escalated to this project or above is the child of this project
  # that the escalated object is itself a child of
   
  # Test that the escalation point of a great-grandchild object escalated to this project or above is the child of this project
  # that the great-grandchild is a descendant of.
  
  # Test that the effective change requests returned for a project are correct.
  
  # Test that the ineffective change requests returned for a project are correct.
  
  # Test that escalated and not_escalated returns for all projects
  def test_escalated
    projects = Project.find(:all)
    projects.each do |p|
      p.escalated_issues
      p.not_escalated_issues
      assert true
    end
  end
end
