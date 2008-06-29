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

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_pmo_session',
    :secret      => '9702bcdcffd0764cf790b72ae5b59f1be1e7fefb3833a89c03eede578c3ff5abf90185787b2f299c86a95d6a2dd35d1959bd1cff4ebd0b827823e49d3b38ab35'
  }

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
# default environment and instance information
# correct in deployment_environment.rb
$hostname = 'localhost'
$app_root = "http://#{$hostname}:3000"

# Deployment_specific environment settings, if any
if File.exist?(File.join(File.dirname(__FILE__), 'deployment_environment.rb'))
  require File.join(File.dirname(__FILE__), 'deployment_environment')
end

# Environment setup for JSCalendar
#ActiveRecord::Base.class_eval do
#  include BoilerPlate::Model::I18n
#end

# environment and instance information
$app_title = 'PMO'
$email_subject_prefix = "\[#{$app_title.upcase}\]"
$email_from_address = "#{$app_title.downcase}-notifier@#{$hostname}"
$email_signoff = "PMO beta"

# Exception Notifier
ExceptionNotifier.exception_recipients = "support@#{$hostname}"
ExceptionNotifier.sender_address = "exception-notifier@#{$hostname}"
