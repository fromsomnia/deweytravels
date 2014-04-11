class Graph < ActiveRecord::Base
	attr_accessible :title

  has_many :topics
  has_many :users

  # Update the Socialcast info of all users in all the Socialcast instances
  # in our system. Also pulled in and save Socialcast users that are not
  # part of the site.

  def self.update_all_users_in_all_domains
    Graph.all.each do |graph|
      users = User.where(:graph_id => graph.id)
      users.each do |user|
        sc = Socialcast.new(user.email, user.password)
        status = sc.authenticate
        if !status['authentication-failure']
          if (User.load_from_sc(sc, graph))
            break
          end
        end
      end
    end
  end

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

	def search(query)
		results = []
		if !query.blank? then
			search_query = query.downcase
			self.users.each do |user|
				search_this = user.first_name + " " + user.last_name
				search_this = search_this.downcase
				if search_this.include?(search_query) then
					results << user
				end
			end
			self.topics.each do |topic|
				search_this = topic.title.downcase
				if search_this.include?(search_query) then
					results << topic
				end
			end
		end
		return results.to_json
	end
end
