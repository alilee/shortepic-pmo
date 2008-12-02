class SalesLeadDetail < ActiveRecord::Base
  include ItemDetail
  
  belongs_to :sales_lead
  
  validates_presence_of :client
end
