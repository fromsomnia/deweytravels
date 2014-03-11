# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'active_record/fixtures'
ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "graphs")
ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "topics")
#ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "users")
ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "topic_user_connections")
ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "user_user_connections")
ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "topic_topic_connections")