desc 'Create YAML fixtures with data taken directly from the database. 
Set RAILS_ENV to override what database the data is taken from.'

# FIXME: C - needs to escape ruby strings
task :dump_fixtures => :environment do 
  sql = "SELECT * FROM %s"
  skip_tables = ["schema_info", "sessions", "pg_ts_dict", "pg_ts_parser", "pg_ts_cfg", "pg_ts_cfgmap"]
  do_tables = ["items"]
  dir = "#{RAILS_ROOT}/test/fixtures/dump"
  begin
    Dir.mkdir(dir)
  rescue
    # ignore if directory already exists
  end
  ActiveRecord::Base.establish_connection
  (ActiveRecord::Base.connection.tables - skip_tables).each do |table_name|
    i = "000"
    File.open("#{dir}/#{table_name}.yml", "w+") do |file|
      data = ActiveRecord::Base.connection.select_all(sql % table_name) 
      file_data = data.inject({}) do |hash, record|
        # replace times and dates in the record with relative dates
        relative_record = Hash.new
        record.each_pair do |k, v|
          next if v.nil?
    
          if k =~ /_on$|_at$/ 
            t = Time.parse(v)
            days_diff = (Time.now - t)/(60*60*24)
            if days_diff < 0
              relative_record[k] = "<%= #{format('%.1f', -days_diff)}.days.from_now.to_formatted_s(:db) %>"
            else
              relative_record[k] = "<%= #{format('%.1f', days_diff)}.days.ago.to_formatted_s(:db) %>"
            end
          else
            relative_record[k] = v
          end

        end 
          
        hash["#{table_name}_#{i.succ!}"] = relative_record
        hash
      end
      file.write file_data.to_yaml
    end
  end
end