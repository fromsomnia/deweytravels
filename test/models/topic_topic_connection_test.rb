require 'test_helper'

class TopicTopicConnectionTest < ActiveSupport::TestCase
  test "test_action" do
    topic1 = Topic.new
    topic1.title = "Test1"
    topic1.graph = Graph.all.first

    topic2 = Topic.new
    topic2.title = "Test2"
    topic2.graph = Graph.all.first

    topic1.save
    topic2.save
    
    old_action_count = Action.count
    topic1.subtopics << topic2
    assert_equal(old_action_count + 1,
                 Action.count)
    
    conn = TopicTopicConnection.find_by subtopic_id: topic2.id, supertopic_id:topic1.id
    assert conn.action
    assert_equal(conn.id, conn.action.table_pkey)
    assert_equal(conn, conn.action.actionable_object)

    user = User.all.first
    assert !conn.is_upvoted_by?(user)
    assert !conn.is_downvoted_by?(user)

    conn.upvoted_by(user)
    assert conn.is_upvoted_by?(user)
    assert !conn.is_downvoted_by?(user)
  end

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
