require 'action'

class TopicUserConnection < ActiveRecord::Base
	# attr_accessible :

	belongs_to :expert, :class_name => "User"
	belongs_to :expertise, :class_name => "Topic"

  def action_class
    AddTopicUserConnectionAction
  end
  include ActionableObject
end
