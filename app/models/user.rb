require 'socialcast'

class User < ActiveRecord::Base
	attr_accessible :fb_id, :first_name, :last_name, :domain, :email, :phone, :username, :password, :image_url
  before_create :set_auth_token, :set_image_url

  belongs_to :graph

	has_many :topic_user_connections, :foreign_key => "expert_id"
	has_many :expertises, -> { uniq }, :through => :topic_user_connections, :source => :expertise

  def name
    return first_name + ' ' + last_name
  end

  def attributes
    super.merge('name' => self.name)
  end

  def add_facebook_friends(friends)
    friends.each do |friend|
      id = friend[:id]
      first_name = friend[:first_name]
      last_name = friend[:last_name]
      image_url = friend[:picture][:data][:url]

      @user = User.find_by_fb_id(id)

      if !@user
        @user = User.register_facebook_user(id, first_name, last_name, nil, image_url)
        self.add_friend(@user)
      elsif !self.friends.include?(@user)
        self.add_friend(@user)
      end
    end
  end

  has_many :friendships,  -> { where(:accepted => true).uniq },
           :class_name => "Friendship", :foreign_key => "user_id"
  has_many :received_friendship_requests,  -> { where(:accepted => false).uniq },
            :class_name => "Friendship", :foreign_key => "friend_id"


  has_many :friends, :through => :friendships, :source => :friend
  has_many :friend_requesters, :through => :received_friendship_requests, :source => :user

  def add_friend(friend)
    self.friends << friend
    friend.friends << self
  end

  # TODO: complete if already requested on other side
  def request_friend(requested)
    requested.friend_requesters << self
  end

  def confirm_friend_request(requester)
    request = Friendship.where(:user_id => requester.id, :friend_id => self.id, :accepted => false).take
    if request
      request.accepted = true
      request.save(:validate => false)

      self.friends << requester
    end
  end

  def remove_friend(friend)
    friendship = Friendship.find_by_user_id_and_friend_id(self.id, friend.id)
    friendship.delete

    friendship = Friendship.find_by_user_id_and_friend_id(friend.id, self.id)
    friendship.delete
  end

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

	def degree
    degrees = [0, 0, 0, 0, 0]
    self.topics.each do |topic|
      index = topic.degree
      degrees[index] = degrees[index] + 1
    end
    if degrees[1] > 1
      return 1
    elsif degrees[2] >1
      return 2
    elsif degrees[3] > 1
      return 3
    elsif degrees[4] >= 1
      return 4
    else
      return 0
    end
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

  def self.suggestions(topic, current_user, previous_suggestions=[])
    @users = previous_suggestions
    @users += (current_user.friends - topic.experts - previous_suggestions).uniq.sample(5)
    @users.sample(5)
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
