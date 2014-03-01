class User < ActiveRecord::Base
	# attr_accessible :

	has_many :expertises, :class_name => "Topic", through: :topic_user_connections, :foreign_key => "expert_id"

	has_many :subordinates, :class_name => "User", through: :user_user_connections, :foreign_key => "superior_id"
	has_many :superiors, :class_name => "User", through: :user_user_connections, :foreign_key => "subordinate_id"

end
