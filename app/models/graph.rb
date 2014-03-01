class Graph < ActiveRecord::Base
	# attr_accessible :

	has_and_belongs_to_many :topics

end
