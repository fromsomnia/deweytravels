class Connection < ActiveRecord::Base
	# attr_accessible :

	has_one :connection_superior, :class_name => "User", :foreign_key => "connection_superior_id"
	has_one :connection_subordinate, :class_name => "User", :foreign_key => "connection_subordinate_id"

	has_one :connection_expert, :class_name => "User", :foreign_key => "connection_expert_id"
	has_one :connection_topic, :class_name => "Topic", :foreign_key => "connection_topic_id"

	belongs_to :graph

end
