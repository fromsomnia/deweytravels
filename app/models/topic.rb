# == Schema Information
#
# Table name: topics
#
#  id          :integer          not null, primary key
#  title       :string(255)
#  image_url   :string(255)
#  graph_id    :integer
#  freebase_id :string(255)
#

require 'freeb/api'

# Represents places in Dewey Travels. Each topic has subtopics, supertopics, and experts.
# Topics in Dewey are closely associated with Freebase, which is used for topic seeding
# and topic image scraping.
# Topics are indexed by title in ElasticSearch through searchkick.
class Topic < ActiveRecord::Base
  searchkick word_start: [:title]
	attr_accessible :title, :image_url, :freebase_image_url
  after_create :set_image
  belongs_to :graph

	has_many :topic_user_connections, :foreign_key => "expertise_id"
	has_many :experts, -> { uniq }, :through => :topic_user_connections, :source => :expert

	has_many :topic_topic_connections, :foreign_key => "supertopic_id"
	has_many :supertopics, :through => :second_topic_topic_connections, :source => :supertopic

	has_many :second_topic_topic_connections, :class_name => "TopicTopicConnection", :foreign_key => "subtopic_id"
	has_many :subtopics, :through => :topic_topic_connections, :source => :subtopic

  # Returns experts of this topic that are friends with a given user.
  # If the only_registered flag is set to true, will only return registered users.
  def experts_which_friends_with(user, only_registered=false)
    result = self.experts.joins(:friendships).where(:friendships => { :friend_id => user.id})
    if only_registered
      result.where(:is_registered => true).all
    else
      result.all
    end
  end

  # Returns a Dewey Topic from a given freebase topic object.
  # If the corresponding Dewey Topic does not exist, will create one and return the newly-
  # created topic.
  def self.from_freebase_topic(freebase_topic)
    default_graph = Graph.find_by_domain('fixtures')
    topic = Topic.find_by_title(freebase_topic.name)
    if !topic
      topic = Topic.new
      topic.image_url = freebase_topic.image_url
      topic.title = freebase_topic.name
      topic.graph = default_graph
      topic.freebase_id = freebase_topic.mid
      topic.save
    end
    topic
  end

  # Seed the Dewey database with countries, cities, and continents as grabbed from Freebase.
  # This operation creates needed topics as well as set up the hierarchy between topics.
  # This function is very slow.
  def self.seed
    default_graph = Graph.find_by_domain('fixtures')
    root = Topic.find_by_title('World')
    if !root
      root = Topic.new
      root.title = 'World'
      root.graph = default_graph
      root.set_image_from_freebase
    end

    continents = Freeb.const_get(:API).search(:type => "/base/locations/continents", :limit => 200)
	continent_list = ["Europe", "North America", "South America", "Antarctica", "Asia", "Australia", "Africa"]
    sleep 1
    continent_topics = []
    continents.each do |continent|
		if continent_list.include?(continent.name)
		  continent_topic = Topic.from_freebase_topic(continent)

		  continent_topics << continent_topic
		  if !root.subtopics.include?(continent_topic) 
			root.subtopics << continent_topic
		  end
		end
    end

    continent_topics.each do |continent_topic|
		 filter_str = "(all type:country (all /location/location/containedby:{ mid:" + continent_topic.freebase_id + "}))"
		countries = Freeb.const_get(:API).search(:filter => filter_str, :limit => 100)
      sleep 1
      countries.each do |country|
        country_topic = Topic.from_freebase_topic(country)

        if !continent_topic.subtopics.include?(country_topic) && (country_topic != continent_topic)
          continent_topic.subtopics << country_topic
        end

        if country_topic.subtopics.length > 0
          next
        end

        filter_str = "(all type:citytown (all /location/location/containedby:{ mid:" + country_topic.freebase_id + "}))"
        cities = Freeb.const_get(:API).search(:filter => filter_str, :limit => 10)
        sleep 1
        cities.each do |city|
          city_topic = Topic.from_freebase_topic(city)

          if !country_topic.subtopics.include?(city_topic) && (city_topic != country_topic)
            country_topic.subtopics << city_topic
          end
        end
      end
    end
  end

  # Returns at most five topic suggestions, given the receiving user and the previous suggestions.
  # The suggestions are random picks from subtopics of topics that the user is already
  # associated to. 
  def self.suggestions(user, previous_suggestions=[])
    @topics = previous_suggestions
    @topics.append(Topic.find_by_title('World'))
    iter = 0
    while @topics.length < 5 and iter < 5 do
      user.expertises.each do |topic|
        @topics += topic.subtopics.sample(5)
      end
      iter += 1
      @topics = (@topics - user.expertises).uniq
    end
    @topics.sample(5)
  end

  # Returns this topic's related topic, defined as a sibling node (node with same parents) of this topic.
	def related
		@related = []
		self.supertopics.each do |top|
			top.subtopics.each do |my_related|
				if(!self.eql?(my_related)) then
					@related << my_related
				end
			end
		end
		return @related
	end

  # Update the images of all the topics in the database, with images scraped from Freebase.
  def self.update_all_images
    Topic.all.each do |topic|
      topic.scrape_image_from_freebase
    end
  end

  # Returns the depth of the current node in the tree / distance of this node from the root.
	def degree
		curr_degree = 0
    node = self 
    root = Topic.find_by_title('World')
    while node.id != root.id
      node = node.supertopics[0]
      curr_degree += 1
    end
		return curr_degree
	end

  # Comparison function between two topics, where the criteria is the topic's node depth.
  def self.sort_by_degree(a, b)
    if a != nil then
      if b != nil then
        return a.degree <=> b.degree
      else
        return 1
      end
    elsif b != nil then
      return -1
    else
      return 0
    end
  end

  # Set the topic's image url property to an image scraped from Freebase.
  # The function picks the top result of a Freebase search with the topic title as the query.
  def set_image_from_freebase
    freebase_topics = Freeb.const_get(:API).search(:query => "#{self.title}")
    if freebase_topics and freebase_topics[0]
      self.freebase_id = freebase_topics[0].id
      self.image_url = freebase_topics[0].image_url
      self.save
    end
  end

  private
    # Set the topic's image url to either the placeholder or a freebase image (if available).
    # The process of scraping the freebase image happens in the background, so the image
    # might not be updated when this function returns.
    def set_image
      if !self.image_url
        self.image_url = '/assets/picture_placeholder.png'
        self.delay.set_image_from_freebase
      end
    end

end
