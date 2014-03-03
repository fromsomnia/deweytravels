class User < ActiveRecord::Base
	# attr_accessible :

	has_many :topic_user_connections
	has_many :topics, :through => :topic_user_connections

	#has_many :subordinates, :class_name => "User", :foreign_key => "superior_id"
	#has_many :superiors, :class_name => "User", :foreign_key => "subordinate_id"

end
