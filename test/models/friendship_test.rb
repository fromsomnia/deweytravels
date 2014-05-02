require 'test_helper'

class FriendshipTest < ActiveSupport::TestCase
  test "basic friendship functionality" do
  	
  	william = users(:william)
  	veni = users(:veni)
  	john = users(:john)
  	stephen = users(:stephen)
  	brett = users(:brett)
  	oren = users(:oren)
  	jay = users(:jay)
  	chris = users(:chris)
  	marc = users(:marc)
  	mike = users(:mike)

  	puts "Each person's initial number of friends"
  	puts "-------------------------"

  	assert_equal(william.getFriends.length , 0)
  	puts "william: " + william.getFriends.length.to_s
  	assert_equal(veni.getFriends.length , 0)
  	puts "veni: " + veni.getFriends.length.to_s
  	assert_equal(john.getFriends.length , 0)
  	puts "john: " + john.getFriends.length.to_s
  	assert_equal(stephen.getFriends.length , 0)
  	puts "stephen: " + stephen.getFriends.length.to_s
  	assert_equal(brett.getFriends.length , 0)
  	puts "brett: " + brett.getFriends.length.to_s
  	assert_equal(oren.getFriends.length , 0)
  	puts "oren: " + oren.getFriends.length.to_s
  	assert_equal(jay.getFriends.length , 0)
  	puts "jay: " + jay.getFriends.length.to_s
  	assert_equal(chris.getFriends.length , 0)
  	puts "chris: " + chris.getFriends.length.to_s
  	assert_equal(marc.getFriends.length , 1)
  	puts "marc: " + marc.getFriends.length.to_s
  	assert_equal(mike.getFriends.length , 1)
  	puts "mike: " + mike.getFriends.length.to_s

  	puts ""
  	puts "Veni requests William as a friend"
  	puts "------------------------"

  	veni.requestFriend(william.id)
  	william.reload
  	veni.reload
  	puts "william friends: " + william.getFriends.length.to_s
    assert_equal(william.getFriends.length, 0, "William should have 0 friends at the moment")
  	puts "william requests: " + william.getFriendRequests.length.to_s
    assert_equal(william.getFriendRequests.length, 1, "William should have 1 friend request")
  	friend = william.getFriendRequests[0]
  	puts "     requested by: " + friend.first_name
    assert_equal(friend.first_name, "Veni", "William's single friend request should be from Veni")
  	puts "veni friends: " + veni.getFriends.length.to_s
    assert_equal(veni.getFriendRequests.length, 0, "Veni should have no current friends")
  	puts "veni requests: " + veni.getFriendRequests.length.to_s
    assert_equal(veni.getFriendRequests.length, 0, "Veni should have no pending friend requests")

  	puts ""
  	puts "Veni adds Jay as a friend (no request process)"
  	puts "-------------------------"

  	veni.addFriend(jay.id)
  	jay.reload
  	veni.reload
  	puts "jay friends: " + jay.getFriends.length.to_s
    assert_equal(jay.getFriends.length, 1, "Jay should have 1 friend, namely Veni")
  	puts "jay requests: " + jay.getFriendRequests.length.to_s
    assert_equal(jay.getFriendRequests.length, 0, "Jay should have no pending friend requests")
  	friend = jay.getFriends[0]
  	puts "jay's friend: " + friend.first_name
    assert_equal(friend.first_name, "Veni", "Jay should have Veni as his only friend")
  	puts "veni friends: " + veni.getFriends.length.to_s
    assert_equal(veni.getFriends.length, 1, "Veni should have a single friend, namely Jay")
  	puts "veni requests: " + veni.getFriendRequests.length.to_s
    assert_equal(veni.getFriendRequests.length, 0, "Veni should have no pending friend requests")
  	friend = veni.getFriends[0]
  	puts "veni's friend: " + friend.first_name
    assert_equal(friend.first_name, "Jay", "Veni's only friend should be Jay")

  	#Check for null users!!!
  	puts""
  	puts"William confirms Veni's friend request"
  	puts"---------------------------"

  	william.confirmFriendRequest(veni.id)
  	william.reload
  	veni.reload
  	puts "william friends: " + william.getFriends.length.to_s
    assert_equal(william.getFriends.length, 1, "William should now have 1 friend")
  	puts "william requests: " + william.getFriendRequests.length.to_s
    assert_equal(william.getFriendRequests.length, 0, "William should no longer have any friend requests")
  	friend = william.getFriends[0]
  	puts "william's friend: " + friend.first_name
    assert_equal(friend.first_name, "Veni", "William's only friend should be Veni")
  	puts "veni friends: " + veni.getFriends.length.to_s
    assert_equal(veni.getFriends.length, 2, "Veni should now have 2 friends")
  	friend = veni.getFriends[0]
  	friend2 = veni.getFriends[1]
  	puts "veni's friends: " + friend.first_name + " " + friend2.first_name
    assert_equal(friend.first_name + " " + friend2.first_name, "Jay William", "Veni should now be friends with Jay and William")
  	puts "veni's requests: " + veni.getFriendRequests.length.to_s
    assert_equal(veni.getFriendRequests.length, 0, "Veni should not have any pending friend requests")
  	friend = jay.getFriends[0]
  	puts "jay's friend: " + friend.first_name
    assert_equal(friend.first_name, "Veni", "Jay should still be friends with only Veni")

  	puts""
  	puts"Veni deletes Jay as a friend"
  	puts"----------------------------"

  	veni.removeFriend(jay.id)
  	veni.reload
  	jay.reload
  	puts "veni's friends: " + veni.getFriends.length.to_s
    assert_equal(veni.getFriends.length, 1, "Veni should now have 1 friend")
  	friend = veni.getFriends[0]
  	puts "veni's friend: " + friend.first_name
    assert_equal(friend.first_name, "William", "Veni's only friend should be William")
  	puts "jay's friends: " + jay.getFriends.length.to_s
    assert_equal(jay.getFriends.length, 0, "Jay should no longer have any friends")
  	puts "william's friends: " + william.getFriends.length.to_s
    assert_equal(william.getFriends.length, 1, "William should still have 1 friend")
  	friend = william.getFriends[0]
  	puts "william's friend: " + friend.first_name
    assert_equal(friend.first_name, "Veni", "William's only friend should still be Veni")

  end
end
