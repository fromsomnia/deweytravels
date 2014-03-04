require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  test "all topics" do
  	puts "Displaying All Topic Information..."
  	puts ""
  	Topic.all.each do |topic|
  		puts "TOPIC ================" + topic.title + "====================="

  		puts "    Topic Title: " + topic.title
  		puts ""

  		puts "    Subtopics: "
  		topic.subtopics.each do |subtopic|
  			puts "        " + subtopic.title
  		end
  		puts ""

  		puts "    Supertopics: "
  		topic.supertopics.each do |supertopic|
  			puts "        " + supertopic.title
  		end
  		puts ""

  		puts "    Related Topics: "
  		topic.related.each do |peer|
  			puts "        " + peer.title
  		end
  		puts ""

  		puts "    Graphs: "
  		topic.graphs.each do |graph|
  			puts "        " + graph.title + " - Size: " + graph.topics.size.to_s
  		end
  		puts ""

  		puts "    Experts: "
  		topic.experts.each do |expert|
  			puts "        " + expert.first_name + " " + expert.last_name + " - Skill: " + expert.expertises.size.to_s
  		end

  		puts "=========================================="
  		puts ""
  		puts ""
  	end
    assert true
   end
end
