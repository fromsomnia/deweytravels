require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "the truth" do
  	william = users(:william)
  	puts william.first_name
  	puts "Skill Set"
  	william.topics.each do |expertise|
  		puts ""
  		puts expertise.title
  		puts "subtopics"
  		expertise.subtopics.each do |l|
  			puts l.title
  		end

  	end
  	assert true
  end
end
