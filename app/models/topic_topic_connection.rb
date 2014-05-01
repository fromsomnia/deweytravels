class TopicTopicConnection < ActiveRecord::Base
	belongs_to :supertopic, :class_name => "Topic"
	belongs_to :subtopic, :class_name => "Topic"

  def in_same_graph
    if supertopic.graph.id != subtopic.graph.id
      errors.add(:supertopic,  "should be in the same graph with the subtopic")
    end
  end

  def graph
    supertopic.graph
  end
end

