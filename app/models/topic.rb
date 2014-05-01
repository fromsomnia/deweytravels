require 'freeb/api'

class Topic < ActiveRecord::Base
	attr_accessible :title, :image_url, :freebase_image_url
  belongs_to :graph

	has_many :topic_user_connections, :foreign_key => "expertise_id"
	has_many :experts, -> { uniq }, :through => :topic_user_connections, :source => :expert

	has_many :topic_topic_connections, :foreign_key => "supertopic_id"
	has_many :supertopics, :through => :second_topic_topic_connections, :source => :supertopic

	has_many :second_topic_topic_connections, :class_name => "TopicTopicConnection", :foreign_key => "subtopic_id"
	has_many :subtopics, :through => :topic_topic_connections, :source => :subtopic


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

  def self.seed
    default_graph = Graph.find_by_domain('fixtures')
    root = Topic.find_by_title('World')
    if !root
      root = Topic.new
      root.title = 'World'
      root.graph = default_graph
      root.set_image_from_freebase
    end

    continents = Freeb.const_get(:API).search(:type => "/location/continent", :limit => 200)
    continent_topics = []
    continents.each do |continent|
      continent_topic = Topic.from_freebase_topic(continent)

      continent_topics << continent_topic
      if !root.subtopics.include?(continent_topic) 
        root.subtopics << continent_topic
      end
    end

    continent_topics.each do |continent_topic|
      filter_str = "(all type:country (any part_of:" + continent_topic.freebase_id + "))"
      countries = Freeb.const_get(:API).search(:filter => filter_str, :limit => 25)

      countries.each do |country|
        country_topic = Topic.from_freebase_topic(country)

        if !continent_topic.subtopics.include?(country_topic) && (country_topic != continent_topic)
          continent_topic.subtopics << country_topic
        end

        if country_topic.subtopics.length > 0
          next
        end

        filter_str = "(all type:city (any part_of:" + country_topic.freebase_id + "))"
        cities = Freeb.const_get(:API).search(:filter => filter_str, :limit => 10)

        cities.each do |city|
          city_topic = Topic.from_freebase_topic(city)

          if !country_topic.subtopics.include?(city_topic) && (city_topic != country_topic)
            country_topic.subtopics << city_topic
          end
        end
      end
    end
  end

  def self.suggestions(user, previous_suggestions=[])
    @topics = previous_suggestions
    @topics.append(Topic.find_by_title('World'))

    while @topics.length < 5 do
      @topics += @topics.sample(1)[0].subtopics.sample(4)
      @topics += Topic.all.sample(2)
      @topics = (@topics - user.expertises).uniq
    end
    @topics
  end

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

  def self.update_all_images
    Topic.all.each do |topic|
      topic.scrape_image_from_freebase
    end
  end

	def degree
		curr_degree = 0
		curr_degree = curr_degree + self.subtopics.size
		curr_degree = curr_degree + self.supertopics.size
		curr_degree = curr_degree + self.experts.size
		return curr_degree
	end


  def set_image_from_freebase
    freebase_topics = Freeb.const_get(:API).search(:query => "#{self.title}")
    if freebase_topics and freebase_topics[0]
      self.freebase_id = freebase_topics[0].id
      self.image_url = freebase_topics[0].image_url
      self.save
    end
  end

  private
    def set_image
      if !self.image_url
        self.image_url = '/assets/picture_placeholder.png'
        self.delay.set_image_from_freebase
      end
    end

end
