namespace :cleanup do
desc "Clear unused brands from existing database"
  task :userdata => :environment do
  	require "#{Rails.root}/lib/tasks/cleanup/db_cleanup"
    DbCleanup.userdata	
  end
end