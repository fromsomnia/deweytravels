require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "all users" do
  	puts "Displaying All User Information..."
  	puts ""
  	User.all.each do |user|
  		puts user.first_name + ":"

  		puts " First Name: " + user.first_name
  		puts " Last Name: " + user.last_name
  		puts " Email: " + user.email
  		puts " Username: " + user.username
  		puts " Password: " + user.password
  		puts " Position: " + user.position
  		puts " Department: " + user.department
  		puts " Image: " + user.image

  		puts ""
  		puts " " + user.first_name + "'s Expertise:"
  		user.expertises.each do |expertise|
  			puts "    " + expertise.title
  		end
  		puts ""
  		puts ""
  	end
  	assert true
  end
end
