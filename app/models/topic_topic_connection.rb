require 'action'

class TopicTopicConnection < ActiveRecord::Base
	belongs_to :supertopic, :class_name => "Topic"
	belongs_to :subtopic, :class_name => "Topic"

  def action_class
    AddTopicTopicConnectionAction
  end
  include ActionableObject
end

