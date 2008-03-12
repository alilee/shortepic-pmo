module TimesheetHelper
  
  def select_for_timesheet_day(dateortime)
    date = dateortime.to_date
    days = system_setting('timesheet_days', 'Timesheet', 7).to_i
    result = Array.new
    date.downto(date-(days-1)) {|d| result << [d.strftime('%a %d'), d.to_s] }
    result
  end
  
  def select_for_current_role(person)
    roles = person.current_roles
    roles.collect {|r| [r.title, r.id] }
  end
  
end
