require 'freeb/api'

class Topic < ActiveRecord::Base
	attr_accessible :title, :image_url, :freebase_image_url
  after_create :set_image
  belongs_to :graph

	has_many :topic_user_connections, :foreign_key => "expertise_id"
	has_many :experts, -> { uniq }, :through => :topic_user_connections, :source => :expert

	has_many :topic_topic_connections, :foreign_key => "supertopic_id"
	has_many :supertopics, :through => :second_topic_topic_connections, :source => :supertopic

	has_many :second_topic_topic_connections, :class_name => "TopicTopicConnection", :foreign_key => "subtopic_id"
	has_many :subtopics, :through => :topic_topic_connections, :source => :subtopic

  def self.seed
    default_graph = Graph.find_by_domain('fixtures')
    root = Topic.find_by_title('World')
    if !root
      root = Topic.new
      root.title = 'World'
      root.graph = default_graph
      root.save
    end

    continents = Freeb.const_get(:API).search(:type => "/location/continent", :limit => 200)
    continents.each do |continent|
      cont = Topic.find_by_title(continent.name)
      if !cont
        cont = Topic.new
        cont.image_url = continent.image_url
        cont.title = continent.name
        cont.graph = default_graph
        cont.save
      else
        cont.graph = default_graph
        cont.save
      end

      if !root.subtopics.include?(cont) 
        root.subtopics << cont
      end
    end

    countries = Freeb.const_get(:API).search({:type => "/location/country",
                              :fips10_4 => {:value => nil, :optional => false}, :limit => 200})

    countries.each do |country|      
      continent_name = ""
      continent_guesses = country.get_property("/location/location/containedby")
      continent_guesses.each do |continent_str|
        continent_freeb = Freeb.const_get(:API).search(:type => "/location/continent", :query => continent_str)
        if continent_freeb  and continent_freeb[0] and continent_freeb[0].name == continent_str
          continent_name = continent_freeb[0].name
          break
        end
      end

      country_topic = Topic.find_by_title(country.name)
      if !country_topic
        country_topic = Topic.new
        country_topic.title = country.name
        country_topic.graph = default_graph
        country_topic.image_url = country.image_url
        country_topic.save
      end

      cont = Topic.find_by_title(continent_name)
      if !cont
        print continent_name
      else
        if !cont.subtopics.include?(country_topic)
          cont.subtopics << country_topic
        end
      end
    end
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
      self.image_url = freebase_topics[0].image_url
      self.save
    end
  end

  private

    def set_image
      self.image_url = '/assets/picture_placeholder.png'
      self.delay.set_image_from_freebase
    end

end
