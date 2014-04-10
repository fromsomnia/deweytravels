require 'test_helper'

class TopicUserConnectionTest < ActiveSupport::TestCase

  test "test_action" do
    topic = Topic.first
    user = User.first
    
    old_action_count = Action.count
    topic.experts << user
    assert_equal(old_action_count + 1,
                 Action.count)
    
    conn = TopicUserConnection.find_by expertise_id: topic.id, expert_id: user.id
    assert conn.action
    assert_equal(conn.id, conn.action.table_pkey)
    assert_equal(conn, conn.action.actionable_object)
  end

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
