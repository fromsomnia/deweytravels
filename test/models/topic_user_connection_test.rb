require 'test_helper'

class TopicUserConnectionTest < ActiveSupport::TestCase

  test "check_validation" do
    new_graph = Graph.new
    new_graph.domain = "new domain"
    new_graph.save

    topic = Topic.all.first
    user = User.all.last
    user.graph = new_graph
    user.save

    assert_raise ActiveRecord::RecordInvalid do
      topic.experts << user
    end

  end
end
