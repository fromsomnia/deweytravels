require 'test_helper'

class UserUserConnectionTest < ActiveSupport::TestCase

  test "test_action" do
    user1 = User.first
    user2 = User.last
    
    old_action_count = Action.count
    user1.subordinates << user2
    assert_equal(old_action_count + 1,
                 Action.count)
    
    conn = UserUserConnection.find_by subordinate_id: user2.id, superior_id:user1.id
    assert conn.action
    assert_equal(conn.id, conn.action.table_pkey)
    assert_equal(conn, conn.action.actionable_object)
  end
end
