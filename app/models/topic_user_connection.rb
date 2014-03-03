class TopicUserConnection < ActiveRecord::Base
	# attr_accessible :

	belongs_to :user
	belongs_to :topic
end
