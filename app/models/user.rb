# == Schema Information
#
# Table name: users
#
#  id            :integer          not null, primary key
#  first_name    :string(255)
#  last_name     :string(255)
#  email         :string(255)
#  phone         :string(255)
#  username      :string(255)
#  password      :string(255)
#  password_enc  :string(255)
#  salt          :string(255)
#  image_url     :string(255)
#  title         :string(255)
#  fb_id         :string(255)
#  graph_id      :integer
#  auth_token    :string(255)
#  is_registered :boolean          default(FALSE)
#

require 'socialcast'

# Represents users in Dewey Travels. Users in Dewey sign up with Facebook, and thus
# its facebook credentials are stored in this class. It is important to note that 
# Dewey users' Facebook friends are also stored in this class, regarless of whether they
# already signed up. The attribute is_registered is important to distinguish
# Dewey users and non-user friends of Dewey users.
# Users are indexed by first name and last name in ElasticSearch through searchkick.

class User < ActiveRecord::Base
  searchkick word_start: [:first_name, :last_name]

	attr_accessible :fb_id, :is_registered, :first_name, :last_name, :domain, :email, :phone, :username, :password, :image_url
  before_create :set_auth_token, :set_image_url

  belongs_to :graph

	has_many :topic_user_connections, :foreign_key => "expert_id"
	has_many :expertises, -> { uniq }, :through => :topic_user_connections, :source => :expertise

  # Returns the full name of this user
  def name
    return first_name + ' ' + last_name
  end

  # Returns the full list of attributes associated with this class.
  def attributes
    # This is a quick hack to make sure that the full name is always sent to Angular,
    # even though it is not a natural attribute of the class.
    super.merge('name' => self.name)
  end

  # Adds a list of Facebook friends to this user.
  # The input is a list of friends, where each friend is represented as a map (as returned by
  # Facebook API). This function will create the user object for each friends (if it has not exist already)
  # and add it to the current user's list of friends.
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

  # Returns the list of friends that are registered on Dewey
  def friends_on_site
    self.friends.where(:is_registered => true).all
  end

  # Add a user object friend as a friend.
  def add_friend(friend)
    self.friends << friend
    friend.friends << self
  end

  # Register Facebook user to Dewey, given its ID, first name, last name, email
  # and image url as grabbed from Facebook API.
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

  # Returns the smallest topic depth that is associated to this user.
  # For example, if a user is listed as an expert on topics Brazil, South America,
  # and Rio Janeiro, this function will return 1 because South America is the closest
  # topic to the root and its distance is 1.
  # Read the documentation of the degree method of Topic class to understand more.
	def degree
    degrees = [0, 0, 0, 0, 0]
    self.expertises.each do |topic|
      index = topic.degree
      degrees[index] = degrees[index] + 1
    end
    if degrees[1] > 0
      return 1
    elsif degrees[2] > 0
      return 2
    elsif degrees[3] > 0
      return 3
    elsif degrees[4] > 0
      return 4
    else
      return 0
    end
	end

  # Comparison function between two users using the smallest topic depth / degree
  # as its differentiator.
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
 
  # Returns at most five user suggestions, given the current user, the topic, and the previous suggestions.
  def self.suggestions(topic, current_user, previous_suggestions=[])
    should_suggest_self = !current_user.expertises.exists?(topic.id)
    num_new_users = should_suggest_self ? 4 : 5
    @users = previous_suggestions
    @users += (current_user.friends - topic.experts - previous_suggestions - [current_user]).uniq.sample(num_new_users)
    if should_suggest_self then
      [current_user]+@users.sample(num_new_users)
    else
      @users.sample(num_new_users)
    end
  end

  private
    # Set the auth token of this user. This is used during authentication.
    def set_auth_token
      return if auth_token.present?

      begin
        self.auth_token = SecureRandom.hex
      end while self.class.exists?(auth_token: self.auth_token)
    end

    # Set the image URL of all users. If does not exist, then the default user image is used.
    def set_image_url
      return if image_url.present?

      begin
        self.image_url = '/assets/default_user_image.png'
      end
    end
end
