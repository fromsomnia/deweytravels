require 'test_helper'

class TopicTopicConnectionTest < ActiveSupport::TestCase

  test "check_validation" do
    new_graph = Graph.new
    new_graph.domain = "new domain"
    new_graph.save

    topic1 = Topic.all.first

    topic2 = Topic.new
    topic2.title = "Test1"
    topic2.graph = new_graph
    topic2.save

    assert_raise ActiveRecord::RecordInvalid do
      topic1.subtopics << topic2
    end

  end

end
