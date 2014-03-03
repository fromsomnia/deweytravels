class Topic < ActiveRecord::Base
	# attr_accessible :

	has_and_belongs_to_many :graphs

	#has_many :topic_user_connections
	#has_many :users, :through => :topic_user_connections

	#has_many :supertopics, :class_name => "Topic", :foreign_key => "subtopic_id"
	#has_many :subtopics, :class_name => "Topic", :foreign_key => "supertopic_id"

end
