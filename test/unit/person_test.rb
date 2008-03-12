require File.dirname(__FILE__) + '/../test_helper'

class PersonTest < Test::Unit::TestCase
  fixtures :items, :person_details, :role_placements, :signatures, :statuses, :codes
  
   # Simple test for addition of 1 valid record.
   def test_add_valid
     p = Person.new
     p.title = 'Test title'
     p.parent = Project.find(:first)
     p.role = Role.find(:first)
     p.person = Person.find(:first)
     p.status = Status.find_by_type_name("Person")
     p.priority_code = Code.find_by_type_name_and_name("Person", "Priority")
     p.escalation = p.parent
     p.updated_by = p.person
     p.detail.email = 'test@shortepic.com'
     p.detail.res_password_hash = 'abc'
     p.detail.res_password_salt = 'xyz'
     p.detail.code_id_timezone = Code.find_by_type_name_and_name("Person", "Timezone")
     assert_valid p.detail
     assert_valid p
     assert p.save
     p1 = Person.find_by_title('Test title')
     assert_not_nil p1
     p_detail = PersonDetail.find_by_person_id(p1.id)
     assert_not_nil p_detail
   end
   
   # Check current items for a person are valid.
   def test_current_items_are_valid
     p = Person.find_by_title('Root person')
     p_items = Item.find(:all, :include => [:status],
       :conditions => ['person_id = ? and generic_stage in (?)',p.id,['1-new','2-pending','3-in progress','4-review']])
     assert_equal(p_items.length, p.current_items.length)
   end
   
   # Check current roles returned are valid.
   def test_current_roles_are_valid
     p = Person.find_by_title('Root person')
     p_assign = RolePlacement.find_all_by_person_id(p.id, :conditions => 'now() between start_on and end_on')
     assert_equal(p_assign.size, p.current_roles.size)
     assert_equal(p_assign.size, p.current_role_ids.size)
     assert_equal(p_assign.size, p.current_role_placements.size)
   end   
   
   # Check signature records returned for sign-offs signed, but not complete are valid.
   def test_signatures_signed_off_and_incomplete_are_valid
     tested = false
     Person.find(:all).each do |p|
       p_sign = Signature.find_all_by_person_id(p.id, :include => {:item => :status},
         :conditions => ['signatures.person_id = ? and signed_at is not null and generic_stage in (?)',
         p.id,['1-new','2-pending','3-in progress','4-review']])
       assert_equal(p_sign.length, p.signoffs_signed_but_incomplete.length)
       tested = true
     end
     assert tested
   end
   
   # Check signature records returned for sign-offs ready for signature are valid.
   # TODO: B - test for signatures ready for sign-off
   # def test_signatures_ready_for_signoff_are_valid
   # end
      
   # Check signature records returned for sign-offs pending future signature are valid.
   # TODO: B - test for signatures pending sign-off
   # def test_signatures_pending_signoff_are_valid
   # end   
end
