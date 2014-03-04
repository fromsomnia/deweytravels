class Graph < ActiveRecord::Base
	# attr_accessible :

	has_and_belongs_to_many :topics

	def experts
		@experts = []
		self.topics.each do |topic|
			topic.experts.each do |expert|
				if !@experts.include?(expert) then
					@experts << expert
				end
			end
		end
		return @experts
	end

end
