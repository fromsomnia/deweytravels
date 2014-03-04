class User < ActiveRecord::Base
	# attr_accessible :

	has_many :topic_user_connections, :foreign_key => "expert_id"
	has_many :expertises, :through => :topic_user_connections, :source => :expertise

	has_many :user_user_connections, :foreign_key => "superior_id"
	has_many :second_user_user_connections, :class_name => "UserUserConnection", :foreign_key => "subordinate_id"

	has_many :subordinates, :through => :user_user_connections, :source => :subordinate
	has_many :superiors, :through => :second_user_user_connections, :source => :superior

	def peers
		@peers = []
		self.superiors.each do |boss|
			boss.subordinates.each do |my_peer|
				@peers << my_peer
			end
		end
		return @peers
	end
end
