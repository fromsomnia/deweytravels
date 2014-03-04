class Topic < ActiveRecord::Base
	# attr_accessible :

	has_and_belongs_to_many :graphs

	has_many :topic_user_connections
	has_many :users, :through => :topic_user_connections

	has_many :topic_topic_connections, :foreign_key => "supertopic_id"
	has_many :supertopics, :through => :topic_topic_connections #, :source => :subtopic

	has_many :topic_topic_connections, :foreign_key => "supertopic_id"
	has_many :subtopics, :through => :topic_topic_connections #, :source => :supertopic

end
