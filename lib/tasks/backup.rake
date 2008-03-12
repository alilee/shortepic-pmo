desc 'Routine backup of a database'
task :backup => :environment do 
  db_name = Item.configurations[RAILS_ENV]["database"]
  backup_dir = '~/backup'
  filename = "#{$hostname}_#{db_name}_#{Time.now.strftime('%G-%V-%u-%H-%M')}.bz2"
  system "mkdir -p #{backup_dir}"
  system "pg_dump #{db_name} | bzip2 > #{backup_dir}/#{filename}"
  system "vacuumdb --dbname=#{db_name} --analyze"
  # TODO: A - transfer file off server (to Amazon s3?)
  # TODO: B - clean up accumulated backups to reduce space
  SubscriptionMailer.deliver_notify_admin('support@'+$hostname, 'Backup', "Backed up to #{filename}\n#{`ls -al #{backup_dir}`}")
end