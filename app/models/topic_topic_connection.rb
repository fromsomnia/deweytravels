# == Schema Information
#
# Table name: topic_topic_connections
#
#  id            :integer          not null, primary key
#  subtopic_id   :integer
#  supertopic_id :integer
#

# Intermediary connection class between two topics - a subtopic-supertopic relationship
class TopicTopicConnection < ActiveRecord::Base
	belongs_to :supertopic, :class_name => "Topic"
	belongs_to :subtopic, :class_name => "Topic"
  validate :in_same_graph, on: :create

  # Returns true if the two nodes involved in this connection is in the same graph
  def in_same_graph
    if supertopic.graph.id != subtopic.graph.id
      errors.add(:supertopic,  "should be in the same graph with the subtopic")
    end
  end

  def graph
    supertopic.graph
  end
end

