#!/usr/bin/env ruby

require 'pathname'
require 'yaml'
require 'erb'
require 'pp'

Cwd = File.dirname(__FILE__)
require Cwd + '/../config/environment.rb'

# load and print the yaml file to test for syntax errors
f = Pathname.new(Cwd + '/test_data.yml')
e = ERB.new(f.read())
yaml = e.result
d = YAML.load(yaml)

$errors = []

if ARGV.empty? || ARGV.include?('systemsettings') then
  SystemSetting.destroy_all
  d['systemsettings'].each { |s|
    s = SystemSetting.new(s)
    puts "storing: '#{s.name}'"
    if !s.save
      puts "skipped: SystemSetting, #{s.name}, #{s.value}"
      $errors << s
    end
  }
  puts "System settings done: #{$errors.length} errors."
end

if ARGV.empty? || ARGV.include?('statuses') then
  Status.destroy_all
  d['statuses'].each { |type_name, h | 
    h.each { |value, generic_stage| 
      s = Status.new(:type_name => type_name, :value => value, :generic_stage => generic_stage)
      puts "storing: '#{value}'"
      if !s.save
        puts "skipped: #{type_name}, #{value}, #{generic_stage} - #{s.errors.full_messages}"
        $errors << s
      end 
    }
  }
  puts "Statuses done: #{$errors.length} errors."
end

if ARGV.empty? || ARGV.include?('codes') then
  Code.destroy_all
  d['codes'].each { |type_name, h | 
    h.each { |code, values | 
      values.each { |value| 
        c = Code.new(:type_name => type_name, :name => code, :value => value)
        puts "storing: '#{value}'"
        if !c.save
          puts "skipped: #{type_name}, #{code}, #{value} - #{c.errors.full_messages}"
          $errors << c
        end
      } 
    }
  }
  puts "Codes done: #{$errors.length} errors."
end

def populate_item(x, title, attrs, type_name)
  x.title = title
  x.project_id = 0
  x.role_id = 0
  x.person_id = 0
  x.status_id = Status.find_by_type_name_and_value(type_name, attrs['status_code']).id
  x.code_id_priority = Code.find_by_type_name_and_value(type_name, attrs['priority_code']).id
  x.project_id_escalation = 0
  x.due_on = attrs['due_on']
  x.description = attrs['description']
  puts "storing: '#{title}'"
  x.save_with_validation(false)
end

if ARGV.empty? || ARGV.include?('projects') then
  Project.destroy_all
  d['projects'].each { |title, attrs|  
    x = Project.new
    populate_item(x, title, attrs, x.class.name)
  }
  puts 'Projects seeded.'
end

if ARGV.empty? || ARGV.include?('people') then
  Person.destroy_all
  d['people'].each { |title, attrs|  
    x = Person.new
    x.detail.email = attrs['email']
    x.detail.password_hash = 'abc'
    x.detail.password_salt = 'xyz'
    x.detail.administrator = attrs['administrator'] != nil
    populate_item(x, title, attrs, x.class.name)
  }
  puts 'People seeded.'
end

if ARGV.empty? || ARGV.include?('roles') then
  Role.destroy_all
  d['roles'].each { |title, attrs|  
    x = Role.new
    populate_item(x, title, attrs, x.class.name)
                 
    if attrs['assignments']
      attrs['assignments'].each { |details| 
        a = x.role_placements.build()
        a.person = Person.find_by_title(details['person'])
        a.start_on = details['start_on']
        a.end_on = details['end_on']
        a.committed_hours = details['committed_hours']
        a.save!
        if details['costs']
          details['costs'].each { |c| 
            ac = a.assignment_costs.build()
            ac.rights_code = Code.find_by_type_name_and_value('Person', c['rights_code'])
            ac.normal_hourly_rate = c['normal_hourly_rate']
            ac.overtime_hourly_rate = c['overtime_hourly_rate']
            ac.normal_hours_per_day = c['normal_hours_per_day']
            ac.save!
          }
        end   
      }
    end                 
  }
  puts "Roles seeded."
end

if ARGV.empty? || ARGV.include?('milestones') then
  Milestone.destroy_all
  d['milestones'].each { |title, attrs|
    x = Milestone.new
    populate_item(x, title, attrs, x.class.name)
  }
  puts "Milestones seeded."
end

if ARGV.empty? || ARGV.include?('issues') then
  Issue.destroy_all
  d['issues'].each { |title, attrs|  
    x = Issue.new
    populate_item(x, title, attrs, x.class.name)
  }
  puts "Issues seeded."
end

if ARGV.empty? || ARGV.include?('actionitems') then
  ActionItem.destroy_all
  d['actionitems'].each { |title, attrs|  
    x = ActionItem.new
    populate_item(x, title, attrs, x.class.name)
  }
  puts "ActionItems seeded."
end

if ARGV.empty? || ARGV.include?('changerequests') then
  ChangeRequest.destroy_all
  d['changerequests'].each { |title, attrs|  
    x = ChangeRequest.new
    populate_item(x, title, attrs, x.class.name)
                 
    if attrs['date_lines']
      attrs['date_lines'].each { |dl| 
        crdl = x.cr_date_lines.build()
        crdl.milestone = Milestone.find_by_title(dl['milestone'])
        crdl.start_on = dl['start_on']
        crdl.end_on = dl['end_on']
        if !crdl.save
          puts "skipping date line due to errors:"
          $errors << crdl
          pp crdl.errors.full_messages
        end
      }
    end
 
    if attrs['effort_lines']
      attrs['effort_lines'].each { |tl| 
        crtl = x.cr_effort_lines.build()
        crtl.milestone = Milestone.find_by_title(tl['milestone'])
        crtl.role = Role.find_by_title(tl['role'])
        crtl.hours = tl['hours']
        crtl.effort_budget = tl['effort_budget']
        if !crtl.save
          puts "skipping effort line due to errors:"
          $errors << crtl
          pp crtl.errors.full_messages
        end
      }
    end
   
    if attrs['expense_lines']
      attrs['expense_lines'].each { |el| 
        crel = x.cr_expense_lines.build()
        crel.milestone = Milestone.find_by_title(el['milestone'])
        crel.role = Role.find_by_title(el['role'])
        crel.code_id_purpose = Code.find_by_type_name_and_value('ChangeRequest',el['purpose_code']).id
        crel.expense_budget = el['expense_budget']
        if !crel.save
          puts "skipping expense line due to errors:"
          $errors << crel
          pp crel.errors.full_messages
        end
      }
    end
  }
  puts "Change requests seeded."
end
# ok, everything is available by title, patch it all up

def patch(title, attrs)
  puts "patching: #{title}"
  i = Item.find_by_title(title)

  i.parent = Item.find_by_title(attrs['project'])
  i.person = Person.find_by_title(attrs['person'])
  i.role = Role.find_by_title(attrs['role'])
  i.escalation = attrs['escalation'] ? Project.find_by_title(attrs['escalation']) : i.parent

  if !i.save
    puts "#{i.id}: #{i.title}"
    puts 'invalid due to errors:' 
    $errors << i
    pp i.errors.full_messages
    i.save_with_validation(false)
  end

  if attrs['associations']
    attrs['associations'].each { |astitle| 
      as = i.associations_from.build(:item_id_to => Item.find_by_title(astitle).id)
      if !as.save
        puts "skipping association due to errors:"
        $errors << as
        pp as.errors.full_messages
      end
    }
  end
  
  if attrs['comments']
    attrs['comments'].each { |comm_details| 
      cm = i.comments.build()
      cm.body = comm_details['body']
      cm.person = Person.find_by_title(comm_details['person'])
      cm.created_at = comm_details['created_at']
      if !cm.save
        puts "skipping comment due to errors:"
        $errors << cm
        pp cm.errors.full_messages
      end
    }
  end
end


if ARGV.empty? || ARGV.include?('projects') then
  d['projects'].each { |title, attrs| patch(title, attrs) }
  puts "Projects done: #{$errors.length} errors."
end

if ARGV.empty? || ARGV.include?('people') then
  d['people'].each { |title, attrs| patch(title, attrs) }
  puts "People done: #{$errors.length} errors."
end

if ARGV.empty? || ARGV.include?('roles') then
  d['roles'].each { |title, attrs| patch(title, attrs) }
  puts "Roles done: #{$errors.length} errors."
end

if ARGV.empty? || ARGV.include?('milestones') then
  d['milestones'].each { |title, attrs| patch(title, attrs) }
  puts "Milestones done: #{$errors.length} errors."
end

if ARGV.empty? || ARGV.include?('issues') then
  d['issues'].each { |title, attrs| patch(title, attrs) }
  puts "Issues done: #{$errors.length} errors."
end

if ARGV.empty? || ARGV.include?('actionitems') then
  d['actionitems'].each { |title, attrs| patch(title, attrs) }
  puts "Actionitems done: #{$errors.length} errors."
end

if ARGV.empty? || ARGV.include?('changerequests') then
  d['changerequests'].each { |title, attrs| patch(title, attrs) }
  puts "Change requests done: #{$errors.length} errors."
end

if ARGV.empty? || ARGV.include?('timesheets') then
  # ok, some timesheets
  Timesheet.destroy_all

  # lines are dependant on Timesheets - so not neccessary to delete
  TimesheetLine.destroy_all

  RolePlacement.find(:all).each { |pa|  
    if pa.committed_hours > 0
      we = pa.start_on + ((13-(pa.start_on.wday+1)) % 7)
      ms = CrEffortLine.find_by_role_id(pa.role.id).milestone
      puts "Timesheets for #{pa.person.title} as #{pa.role.title} since #{we} on #{ms.title}"
        
      while we < Date.today
        t = Timesheet.new
          t.title = "T/s for #{pa.person.title} for w/e #{we}"
          t.project_id = pa.person.project_id
          t.project_id_escalation = t.project_id
          t.person_id = pa.person.person_id
          t.role_id = pa.role.id
          t.status = Status.find_by_type_name_and_value('Timesheet','Approved')
          t.priority_code = Code.find_by_type_name_and_name_and_value('Timesheet','Priority','b-normal')
          t.due_on = we
          t.detail.period_ending_on = we
          t.detail.person_id_worker = pa.person.id
          if !t.valid?
            puts t.errors.full_messages 
            $errors << t
          end
          t.save
  
          tl = t.timesheet_lines.build()
          tl.milestone_id = ms.id
          tl.role = pa.role
          tl.worked_on = we
          tl.normal_hours = 8 * (we.jd - [we.jd-5, pa.start_on.jd].max)
          if !tl.valid?
            puts tl.errors.full_messages
            $errors << tl
          end
          tl.save
      
          we = we + 7
          putc '.'
          $stdout.flush
        end
      puts '-'
    end
  }
end

puts "All done: #{$errors.length} errors."
$errors.each { |e| 
  puts '======================================='
  pp e 
}
