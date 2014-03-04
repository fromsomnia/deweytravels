require 'test_helper'

class GraphTest < ActiveSupport::TestCase
  test "all graphs" do
  	puts "Displaying All Graph Information..."
  	puts ""
  	Graph.all.each do |graph|
  		puts "GRAPH ================= " + graph.title + " =================="
  		puts "    Graph Title: " + graph.title
  		puts ""

  		puts "    Experts Involved: (" + graph.experts.size.to_s + ")"
  		graph.experts do |expert|
  			puts "        " + expert.first_name + " " + expert.last_name + " - Skill: " + expert.expertises.size.to_s
  		end
  		puts ""

  		puts "    Constituent Topics: (" + graph.topics.size.to_s + ")"
  		graph.topics.each do |topic|
  			puts "        " + topic.title + " - Experts: " + topic.experts.size.to_s
  		end
  		puts "======================================="
  		puts ""
  		puts ""
  	end
    assert true
  end
end
