class Topic < ActiveRecord::Base
	# attr_accessible :

	has_and_belongs_to_many :graphs

	has_many :experts, :class_name => "User", through: :topic_user_connections, :foreign_key => "expertise_id"

	has_many :supertopics, :class_name => "Topic", through: :topic_topic_connections, :foreign_key => "subtopic_id"
	has_many :subtopics, :class_name => "Topic", through: :topic_topic_connections, :foreign_key => "supertopic_id"

end
