# This defines a deployment "recipe" that you can feed to capistrano
# (http://manuals.rubyonrails.com/read/book/17). It allows you to automate
# (among other things) the deployment of your application.

require 'mongrel_cluster/recipes'

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================
# You must always specify the application and repository for every recipe. The
# repository must be the URL of the repository you want this recipe to
# correspond to. The deploy_to path must be the path on each machine that will
# form the root of the application path.

set :application, "pmo"
set :branch, "tags/mymerch"
set :repository, "http://shortepic.svnrepository.com/svn/#{application}/#{branch}"

# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# :primary => true.

role :web, "action"
role :app, "action"
role :db,  "action", :primary => true

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
set :user, "test1"              # defaults to the currently logged in user
ssh_options[:port] = 20220

set :db_user, user
set :db_password, "abc"
set :deploy_to, "/home/#{user}/#{application}"
set :svn_username, "pmo"
set :svn_password, "<password>"

set :mongrel_servers, 2
set :mongrel_port, 8001
set :mongrel_user, user
set :mongrel_group, user
set :use_sudo, false
set :mongrel_conf, "#{deploy_to}/#{shared_dir}/config/mongrel_cluster.yml"

# =============================================================================
# TASKS
# =============================================================================
# Define tasks that run on all (or only some) of the machines. You can specify
# a role (or set of roles) that each task should be executed on. You can also
# narrow the set of servers to a subset of a role by specifying options, which
# must match the options given for the servers to select (like :primary => true)

desc "Create database.yml in shared/config" 
task :after_setup do
  run "mkdir -p #{deploy_to}/#{shared_dir}/config" 
  put File.read('config/environment.rb'), "#{deploy_to}/#{shared_dir}/config/environment.rb"

  database_configuration = render :template => <<-EOF
login: &login
  adapter: postgresql
  username: <%= db_user %>
  password: <%= db_password %>

development:
  database: <%= "#{user}_dev" %>
  <<: *login

test:
  database: <%= "#{user}_tst" %>
  <<: *login

production:
  database: <%= "#{user}_prd" %>
  <<: *login
EOF
  put database_configuration, "#{deploy_to}/#{shared_dir}/config/database.yml" 
  
  pound_configuration = render :template => <<-EOF
ListenHTTP
  Address 0.0.0.0
  Port    <%= mongrel_port-1 %>
  
  Service
    <% mongrel_servers.times do |i| %>
    Backend
      Address 127.0.0.1
      Port    <%= mongrel_port + i %>
    End
    <% end %>
  End
End  
EOF
  put pound_configuration, "#{deploy_to}/#{shared_dir}/config/pound.conf"
  run "chown :mongrel #{deploy_to}/#{shared_dir}/config/pound.conf"
  
  run "ln -sf #{deploy_to}/#{shared_dir}/config/mongrel_cluster.yml /etc/mongrel_cluster/#{user}_#{application}.yml"
  run "ln -sf #{deploy_to}/#{shared_dir}/config/pound.conf /usr/local/etc/pound/#{user}_#{application}.conf"
end

desc "Link in the production database.yml" 
task :after_update_code do
  run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml" 
  #run "ln -nfs #{deploy_to}/#{shared_dir}/config/environment.rb #{release_path}/config/environment.rb"   
end

desc "Create initial data set"
task :remote_initial_data, :roles => :app do
  run "cd #{current_path} && rake RAILS_ENV=#{rails_env} initial_data"
end

desc "Create test data set"
task :remote_test_data, :roles => :app do
  run "cd #{current_path} && rake RAILS_ENV=#{rails_env} load_fixtures"
end

desc 'Install rake backup as cron job'
task :install_cron_backup, :roles => :db do
  old_cron = ''
  run "crontab -l" do |ch,s,data|
    old_cron << (data.chomp+"\n")
  end

  new_cron = old_cron
  new_cron << "30 */6 * * * \tcd #{current_path} && rake RAILS_ENV=#{rails_env} backup\n"
  put new_cron, "/tmp/new_cron"
  
  run "crontab /tmp/new_cron"
  delete "/tmp/new_cron"
end

# FIXME: D - This should only run on one server
desc 'Install rake deliver_summary_emails as cron job'
task :install_cron_summary_emails, :roles => :app do
  old_cron = ''
  run "crontab -l" do |ch,s,data|
    old_cron << (data.chomp+"\n")
  end

  new_cron = old_cron
  new_cron << "39 0 * * * \tcd #{current_path} && rake RAILS_ENV=#{rails_env} deliver_summary_emails\n"
  put new_cron, "/tmp/new_cron"
  
  run "crontab /tmp/new_cron"
  delete "/tmp/new_cron"
end


# Tasks may take advantage of several different helper methods to interact
# with the remote server(s). These are:
#
# * run(command, options={}, &block): execute the given command on all servers
#   associated with the current task, in parallel. The block, if given, should
#   accept three parameters: the communication channel, a symbol identifying the
#   type of stream (:err or :out), and the data. The block is invoked for all
#   output from the command, allowing you to inspect output and act
#   accordingly.
# * sudo(command, options={}, &block): same as run, but it executes the command
#   via sudo.
# * delete(path, options={}): deletes the given file or directory from all
#   associated servers. If :recursive => true is given in the options, the
#   delete uses "rm -rf" instead of "rm -f".
# * put(buffer, path, options={}): creates or overwrites a file at "path" on
#   all associated servers, populating it with the contents of "buffer". You
#   can specify :mode as an integer value, which will be used to set the mode
#   on the file.
# * render(template, options={}) or render(options={}): renders the given
#   template and returns a string. Alternatively, if the :template key is given,
#   it will be treated as the contents of the template to render. Any other keys
#   are treated as local variables, which are made available to the (ERb)
#   template.

desc "Demonstrates the various helper methods available to recipes."
task :helper_demo do
  # "setup" is a standard task which sets up the directory structure on the
  # remote servers. It is a good idea to run the "setup" task at least once
  # at the beginning of your app's lifetime (it is non-destructive).
  setup

  buffer = render("maintenance.rhtml", :deadline => ENV['UNTIL'])
  put buffer, "#{shared_path}/system/maintenance.html", :mode => 0644
  sudo "killall -USR1 dispatch.fcgi"
  run "#{release_path}/script/spin"
  delete "#{shared_path}/system/maintenance.html"
end

# You can use "transaction" to indicate that if any of the tasks within it fail,
# all should be rolled back (for each task that specifies an on_rollback
# handler).

desc "A task demonstrating the use of transactions."
task :long_deploy do
  transaction do
    update_code
    disable_web
    symlink
    migrate
  end

  restart
  enable_web
end
