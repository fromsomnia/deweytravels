class Graph < ActiveRecord::Base
	attr_accessible :title

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

	def self.search(query)
		results = []
		if !query.blank? then
			search_query = query.downcase
			User.all.each do |user|
				search_this = user.first_name + " " + user.last_name
				search_this = search_this.downcase
				if search_this.include?(search_query) then
					results << user
				end
			end
			Topic.all.each do |topic|
				search_this = topic.title.downcase
				if search_this.include?(search_query) then
					results << topic
				end
			end
		end
		return results.to_json
	end
end
