desc "This task is called by the Heroku scheduler add-on"
task :update_topics => :environment do
  Topic.update_all_images
end

task :update_users => :environment do
  User.update_all_domains
end
