require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "all users" do
  	puts "Displaying All User Information..."
  	puts ""
  	User.all.each do |user|
  		puts "USER =================" + user.first_name + "=================="

  		puts " First Name: " + user.first_name
  		puts " Last Name: " + user.last_name
  		puts " Email: " + user.email
  		puts " Username: " + user.username
  		puts " Password: " + user.password
  		puts " Position: " + user.position
  		puts " Department: " + user.department
  		puts " Image: " + user.image

  		puts ""
  		puts " " + user.first_name + "'s Superiors:"
  		user.superiors.each do |superior|
  			puts "    " + superior.first_name + " " + superior.last_name
  		end

  		puts ""
  		puts " " + user.first_name + "'s Peers:"
  		user.peers.each do |peer|
  			puts "    " + peer.first_name + " " + peer.last_name
  		end

  		puts ""
  		puts " " + user.first_name + "'s Subordinates:"
  		user.subordinates.each do |subordinate|
  			puts "    " + subordinate.first_name + " " + subordinate.last_name
  		end

  		puts ""
  		puts " " + user.first_name + "'s Expertise: (Skill: " + user.expertises.size.to_s + ")"
  		user.expertises.each do |expertise|
  			puts "    " + expertise.title
  		end

  		puts "======================================="
  		puts ""
  		puts ""
  	end
  	assert true
  end
end
