require 'freeb/api'

class Topic < ActiveRecord::Base
	attr_accessible :title, :image_url, :freebase_topic_id, :freebase_image_url

  belongs_to :graph

	has_many :topic_user_connections, :foreign_key => "expertise_id"
	has_many :experts, :through => :topic_user_connections, :source => :expert, :uniq => :true

	has_many :topic_topic_connections, :foreign_key => "supertopic_id"
	has_many :supertopics, :through => :second_topic_topic_connections, :source => :supertopic

	has_many :second_topic_topic_connections, :class_name => "TopicTopicConnection", :foreign_key => "subtopic_id"
	has_many :subtopics, :through => :topic_topic_connections, :source => :subtopic

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

  def scrape_image_from_freebase
    freebase_topics = Freeb.const_get(:API).search(:query => "#{self.title}")
    if freebase_topics and freebase_topics[0]
      self.freebase_topic_id = freebase_topics[0].mid
      self.freebase_image_url = freebase_topics[0].image_url
      self.save
    end

    # Hacky solution, because Angular doesn't accept dynamic attribute(?)
    # Ideally we don't need the below lines, make freebase_image_url private and service all
    # public requests to image_url.
    if not self.freebase_image_url
      self.freebase_image_url = '/assets/picture_placeholder.png'
      self.save
    end
  end

  def image_url
    if not self.freebase_image_url
      return '/assets/picture_placeholder.png'
    else
      return self.freebase_image_url
    end
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

end
