require File.dirname(__FILE__) + '/../test_helper'

class RequirementTest < Test::Unit::TestCase
  fixtures :items, :requirement_details, :statuses, :codes

  # Simple test for addition of 1 valid record.
  def test_add_valid
    r = Requirement.new
    r.title = 'Test requirement'
    r.parent = Project.find(:first)
    r.role = Role.find(:first)
    r.person = Person.find(:first)
    r.status = Status.find_by_type_name("Requirement")
    r.priority_code = Code.find_by_type_name_and_name("Requirement", "Priority")
    r.escalation = r.parent
    r.updated_by = r.person
    r.detail.type_code = Code.find_by_type_name_and_name("Requirement", "Type")
    r.detail.area_code = Code.find_by_type_name_and_name("Requirement", "Area")
    assert_valid r
    assert r.save
    r1 = Requirement.find_by_title(r.title)
    r_detail = RequirementDetail.find_by_requirement_id(r1.id)
    assert_not_nil r_detail
  end
  
  # test for adding a child
  def test_add_child
    r = Requirement.new
    r.title = 'Test requirement'
    r.parent = Project.find(:first)
    r.role = Role.find(:first)
    r.person = Person.find(:first)
    r.status = Status.find_by_type_name("Requirement")
    r.priority_code = Code.find_by_type_name_and_name("Requirement", "Priority")
    r.escalation = r.parent
    r.updated_by = r.person
    r.detail.type_code = Code.find_by_type_name_and_name("Requirement", "Type")
    r.detail.area_code = Code.find_by_type_name_and_name("Requirement", "Area")
    assert_valid r
    assert r.save
    r1 = Requirement.find_by_title(r.title)
    r_detail = RequirementDetail.find_by_requirement_id(r1.id)
    assert_not_nil r_detail
    
    s = Requirement.new
    s.title = 'Test requirement 2'
    s.parent = Project.find(:first)
    s.role = Role.find(:first)
    s.person = Person.find(:first)
    s.status = Status.find_by_type_name("Requirement")
    s.priority_code = Code.find_by_type_name_and_name("Requirement", "Priority")
    s.escalation = s.parent
    s.updated_by = s.person
    s.detail.type_code = Code.find_by_type_name_and_name("Requirement", "Type")
    s.detail.area_code = Code.find_by_type_name_and_name("Requirement", "Area")
    s.detail.requirement_detail_id_parent = r.detail.id
    assert_valid s
    assert s.save
    s1 = Requirement.find_by_title(s.title, :include => :detail)
    s_detail = RequirementDetail.find_by_requirement_id(s1.id)
    assert_not_nil s_detail

    assert_not_nil s1.detail.parent
    assert_equal(s1.detail.parent.requirement.title, r.title)
  end

end
