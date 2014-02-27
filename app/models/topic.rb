class Topic < ActiveRecord::Base
	# attr_accessible :

	belongs_to :graph

	has_many :experts, :class_name => "User", :foreign_key => "expert_id"
	belongs_to :expertise, :class_name => "User"

	belongs_to :subtopic, :class_name => "Topic"
	belongs_to :supertopics, :class_name => "Topic"
	belongs_to :peer, :class_name => "Topic"

	has_many :subtopics, :class_name => "Topic", :foreign_key => "subtopic_id"
	has_many :supertopics, :class_name => "Topic", :foreign_key => "supertopic_id"
	has_many :peers, :class_name => "Topic", :foreign_key => "peer_id"

	belongs_to :connection_topic, :class_name => "Connection"

end
