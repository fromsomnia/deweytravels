class User < ActiveRecord::Base
	# attr_accessible :

	has_many :topic_user_connections, :foreign_key => "expert_id"
	has_many :expertises, :through => :topic_user_connections, :source => :expertise

	has_many :user_user_connections, :foreign_key => "superior_id"
	has_many :user_user_connections, :foreign_key => "subordinate_id"

	has_many :subordinates, :through => :user_user_connections, :source => :subordinate
	has_many :superiors, :through => :user_user_connections, :source => :superior

end
