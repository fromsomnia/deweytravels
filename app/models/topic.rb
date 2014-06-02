require 'freeb/api'

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

  def experts_which_friends_with(user, only_registered=false)
    result = self.experts.joins(:friendships).where(:friendships => { :friend_id => user.id})
    if only_registered
      result.where(:is_registered => true).all
    else
      result.all
    end
  end

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
    sleep 1
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
      countries = Freeb.const_get(:API).search(:filter => filter_str, :limit => 50)
      sleep 1
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
    node = self 
    root = Topic.find_by_title('World')
    while node.id != root.id
      node = node.supertopics[0]
      curr_degree += 1
    end
		return curr_degree
	end

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
