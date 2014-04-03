class TopicTopicConnection < ActiveRecord::Base
	belongs_to :supertopic, :class_name => "Topic"
	belongs_to :subtopic, :class_name => "Topic"

  def action_class
    AddTopicTopicConnectionAction
  end
  include ActionableObject
end

class AddTopicTopicConnectionAction < Action
  self.action_object_class = TopicTopicConnection
end

