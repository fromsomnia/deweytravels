# == Schema Information
#
# Table name: graphs
#
#  id     :integer          not null, primary key
#  domain :string(255)
#

# Represents a graph of users and expertises. This will be particularly useful
# when Dewey has multiple instances.
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

  # Search for a particular query in this graph, powered by elastic search.
  # This function will search over topics and users. Topics are indexed by title,
  # and users are indexed by first name and last name. All searches are
  # by start-of-word rule.
	def search(query)
		results = []
		if !query.blank? then
      topic_results = (Topic.search query, fields: [{title: :word_start}]).results
      user_results =  (User.search query, fields: [{first_name: :word_start}, {last_name: :word_start}]).results

      results = topic_results + user_results
		end
    results
	end
end
