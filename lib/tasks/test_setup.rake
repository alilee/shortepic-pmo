# This overrides the test database preparation to insert the tsearch2 definitions.
# Each time 'rake test' is run the database is dropped and recreated. The assumption
# is that the db/schema.rb will recreate the entire database. Currently it doesn't
# export types which is how tsearch2 is implemented in PG. This is handled by
# migrations in dev and prod.
#
# The environment.rb file also contains a line to prevent the schema dumper dumping
# the pg_ts_* files which causes them to be recreated empty on schema load.
#
# FIXME: C - This should call the rake super-task rather than copy and paste.
namespace :db do
  namespace :test do
    desc "Empty the test database and initialise tsearch2"
    task :purge => :environment do
      abcs = ActiveRecord::Base.configurations
      case abcs["test"]["adapter"]
        when "postgresql"
          ENV['PGHOST']     = abcs["test"]["host"] if abcs["test"]["host"]
          ENV['PGPORT']     = abcs["test"]["port"].to_s if abcs["test"]["port"]
          ENV['PGPASSWORD'] = abcs["test"]["password"].to_s if abcs["test"]["password"]
          enc_option = "-E #{abcs["test"]["encoding"]}" if abcs["test"]["encoding"]
      
          ActiveRecord::Base.clear_active_connections!
          `dropdb -U "#{abcs["test"]["username"]}" #{abcs["test"]["database"]}`
          `createdb #{enc_option} -U "#{abcs["test"]["username"]}" #{abcs["test"]["database"]}`
          
          # These lines pipe the tsearch2.sql into the test database. 
          ts_filename = `locate contrib/tsearch2.sql | head -n 1`.strip
          `psql -U "#{abcs["test"]["username"]}" #{abcs["test"]["database"]} < #{ts_filename}`
        else
          raise "Task not defined for '#{abcs["test"]["adapter"]}'"
      end
    end
  end
end