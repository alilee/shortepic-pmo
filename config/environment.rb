#
# NOTE: This file is overridden on deployment to a replacement in shared/config.
#

# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake create_sessions_table')
  # TODO: C - set up periodic session clean-up
  config.action_controller.session_store = :active_record_store

  # Enable page/fragment caching by setting a file-based store
  # (remember to create the caching directory and make it readable to the application)
  # config.action_controller.fragment_cache_store = :file_store, "#{RAILS_ROOT}/cache"

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # Use Active Record's schema dumper instead of SQL when creating the test database
  # (enables use of different database adapters for development and test environments)
  # config.active_record.schema_format = :ruby

  # See Rails::Configuration for more options
  # ActionMailer
  config.action_mailer.smtp_settings = {
    :address => 'mail.shortepic.com',
    :domain => 'application.shortepic.com'
  }
  
end

require 'postgres_extensions'
ActiveRecord::SchemaDumper.ignore_tables << /^pg_ts_.*/

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Include your application configuration below

# Environment setup for JSCalendar
#ActiveRecord::Base.class_eval do
#  include BoilerPlate::Model::I18n
#end

# environment and instance information
if RUBY_PLATFORM =~ /win32/
    svninfo = `svn info "#{File.dirname(__FILE__)}"`
else
    svninfo = `/usr/bin/env svn info #{File.dirname(__FILE__)}`
end
svninfo =~ /Last Changed Rev: (\d+)\n/
$app_rev = $1
svninfo =~ /URL: (.+)\n/
$app_branch = $1 
$hostname = Socket.gethostname
$app_root = "http://#{$hostname}:8000"

$app_title = 'PMO'
$email_subject_prefix = "\[#{$app_title.upcase}\]"
$email_from_address = "#{$app_title.downcase}-notifier@#{$hostname}"
$email_signoff = "Consultant Manager Beta"

# Exception Notifier
ExceptionNotifier.exception_recipients = "support@#{$hostname}"
ExceptionNotifier.sender_address = "exception-notifier@#{$hostname}"
