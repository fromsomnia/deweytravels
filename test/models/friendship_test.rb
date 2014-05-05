require 'test_helper'

class FriendshipTest < ActiveSupport::TestCase
  test "test request friends functionality" do
    user1 = User.first
    user2 = User.last

    user1.request_friend(user2.id)
    assert_equal(user2.get_friends.length, 0)
    assert_equal(user2.get_friend_requests.length, 1)

  	friend = user2.get_friend_requests[0]
    assert_equal(friend, user1)
    assert_equal(friend.get_friend_requests.length, 0)

  	user2.confirm_friend_request(user1.id)

    user1.reload
    user2.reload

    assert_equal(user2.get_friend_requests.length, 0)
    assert_equal(user1.get_friends.length, 1)
    assert_equal(user2.get_friends.length, 1)
    assert_equal(user2.get_friends[0], user1)
  end

  test "test direct adding friends" do
    user1 = User.first
    user2 = User.last

    user1.add_friend(user2.id)

    user1.reload
    user2.reload
    assert_equal(user2.get_friends.length, 1)
    assert_equal(user2.get_friend_requests.length, 0)

  	friend = user2.get_friends[0]

    assert_equal(friend, user1)
    assert_equal(user1.get_friends.length, 1)
    assert_equal(user1.get_friend_requests.length, 0)
    assert_equal(user1.get_friends[0], user2)
  end


  test "test removing friends" do
    user1 = User.first
    user2 = User.last

    user1.add_friend(user2.id)

    user1.reload
    user2.reload
    assert_equal(user1.get_friends.length, 1)

    user1.remove_friend(user2.id)

    user1.reload
    user2.reload
    assert_equal(user1.get_friends.length, 0)
    assert_equal(user2.get_friends.length, 0)
  end
end
