require 'socialcast'

class User < ActiveRecord::Base
	attr_accessible :fb_id, :first_name, :last_name, :domain, :email, :phone, :username, :password, :position, :department, :image_url
  before_create :set_auth_token, :set_image_url

  belongs_to :graph

	has_many :topic_user_connections, :foreign_key => "expert_id"
	has_many :expertises, -> { uniq }, :through => :topic_user_connections, :source => :expertise

	has_many :user_user_connections, :foreign_key => "superior_id"
	has_many :second_user_user_connections, :class_name => "UserUserConnection", :foreign_key => "subordinate_id"

	has_many :subordinates, :through => :user_user_connections, :source => :subordinate
	has_many :superiors, :through => :second_user_user_connections, :source => :superior

  has_many :user_action_votes, :foreign_key => "action_id"
  has_many :upvoted_actions, :through => :user_action_votes, :source => :action

  def self.register_facebook_user(id, first_name, last_name, email, image_url)
    # TODO: register facebook users to a different domain?
    graph = Graph.find_by_domain('fixtures')
    if not graph
      graph = Graph.new
      graph.domain = 'fixtures'
      graph.save
    end

    new_user = User.new
    new_user.fb_id = id
    new_user.first_name = first_name
    new_user.last_name = last_name
    new_user.email = email
    new_user.image_url = image_url
    new_user.graph = graph
    new_user.save
    return new_user
  end

	def peers
		@peers = []
		self.superiors.each do |boss|
			boss.subordinates.each do |my_peer|
				if(!self.eql?(my_peer)) then
					@peers << my_peer
				end
			end
		end
		return @peers
	end

	def degree
		curr_degree = 0
		curr_degree = curr_degree + self.expertises.size
		return curr_degree
	end

  private
    def set_auth_token
      return if auth_token.present?

      begin
        self.auth_token = SecureRandom.hex
      end while self.class.exists?(auth_token: self.auth_token)
    end

    def set_image_url
      return if image_url.present?

      begin
        self.image_url = '/assets/default_user_image.png'
      end
    end
end
