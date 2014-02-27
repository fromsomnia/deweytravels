class Graph < ActiveRecord::Base
	# attr_accessible :

	has_many :topics
	has_many :users, :through => "topics"
end
