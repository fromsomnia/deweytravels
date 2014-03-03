class TopicTopicConnection < ActiveRecord::Base
	# attr_accessible :

	belongs_to :subtopic, :class_name => "Topic"
	belongs_to :supertopic, :class_name => "Topic"

end
