ENV["RAILS_ENV"] ||= "test"

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'


class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!


  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  # fixtures :graphs, :topics, :users, :topic_user_connections, :topic_topic_connections, :user_user_connections
  
  fixtures :users

  # Add more helper methods to be used by all tests here...
end

require 'mocha/mini_test'
