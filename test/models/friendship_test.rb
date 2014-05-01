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

  	puts "each number of friends"
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
  	assert_equal(marc.getFriends.length , 0)
  	puts "marc: " + marc.getFriends.length.to_s
  	assert_equal(mike.getFriends.length , 0)
  	puts "mike: " + mike.getFriends.length.to_s

  	puts ""

  	veni.requestFriend(william.id)
  	puts "william friends: " + william.friendships.length.to_s
  	puts "william requests: " + william.getFriendRequests.length.to_s
  	friend = william.getFriendRequests[0]
  	puts "     requested by: " + friend.first_name
  	puts "veni friends: " + veni.getFriends.length.to_s
  	puts "veni requests: " + veni.getFriendRequests.length.to_s

  	puts ""

  	veni.addFriend(jay.id)
  	puts "jay friends: " + jay.getFriends.length.to_s
  	puts "jay requests: " + jay.getFriendRequests.length.to_s
  	friend = jay.getFriends[0]
  	puts "jay's friend: " + friend.first_name
  	puts "veni friends: " + veni.getFriends.length.to_s
  	puts "veni requests: " + veni.getFriendRequests.length.to_s
  	friend = veni.getFriends[0]
  	puts "veni's friend: " + friend.first_name

  	#Check for null users!!!

  	william.confirmFriendRequest(veni.id)
  	puts "william friends: " + william.getFriends.length.to_s
  	puts "william requests: " + william.getFriendRequests.length.to_s
  	friend = william.getFriends[0]
  	puts "william's friend: " + friend.first_name
  	puts "veni friends: " + veni.getFriends.length.to_s
  	friend = veni.getFriends[0]
  	friend2 = veni.getFriends[1]
  	puts "veni's friends: " + friend.first_name + " " + friend.first_name
  	puts "veni's requests: " + veni.getFriendRequests.length.to_s
  	friend = jay.getFriend[0]
  	puts "jay's friend: " + friend.first_name

  	veni.removeFriend(jay.id)
  	puts "veni's friends: " + veni.getFriends.length.to_s
  	friend = veni.getFriends[0]
  	puts "veni's friend: " + friend.first_name
  	puts "jay's friends: " + jay.getFriends.length.to_s
  	puts "william's friends: " + william.getFriends.length.to_s
  	friend = william.getFriends[0]
  	puts "william's friend: " + friend.first_name

  #   assert true
  end
end
