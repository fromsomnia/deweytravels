require 'test_helper'

class TopicUserConnectionTest < ActiveSupport::TestCase

  test "test_action" do
    topic1 = Topic.new
    topic1.title = "Test1"

    topic1.save

    user = User.first
    
    old_action_count = Action.count
    topic1.experts << user
    assert_equal(old_action_count + 1,
                 Action.count)
    
    conn = TopicUserConnection.find_by expertise_id: topic1.id, expert_id: user.id
    assert conn.action
    assert_equal(conn.id, conn.action.table_pkey)
    assert_equal(conn, conn.action.actionable_object)
  end
end
