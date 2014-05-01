require 'socialcast'

class User < ActiveRecord::Base
<<<<<<< HEAD
	attr_accessible :fb_id, :first_name, :last_name, :domain, :email, :phone, :username, :password, :image_url
  before_create :set_auth_token, :set_image_url
=======
	attr_accessible :fb_id, :first_name, :last_name, :domain, :email, :phone, :username, :password, :position, :department, :image_url
  #before_create :set_auth_token, :set_image_url
>>>>>>> friendships

  belongs_to :graph

	has_many :topic_user_connections, :foreign_key => "expert_id"
	has_many :expertises, -> { uniq }, :through => :topic_user_connections, :source => :expertise

	has_many :user_user_connections, :foreign_key => "superior_id"
	has_many :second_user_user_connections, :class_name => "UserUserConnection", :foreign_key => "subordinate_id"

	has_many :subordinates, :through => :user_user_connections, :source => :subordinate
	has_many :superiors, :through => :second_user_user_connections, :source => :superior


  def add_facebook_friends(friends)
    # TODO(veni): pending on william's work, this might go to a Friends class.

    friends.each do |friend|
      id = friend[:id]
      first_name = friend[:first_name]
      last_name = friend[:last_name]
      image_url = friend[:picture][:data][:url]

      @user = User.find_by_fb_id(id)

      if !@user
        @user = User.register_facebook_user(id, first_name, last_name, nil, image_url)
        self.subordinates << @user
      end
    end
  end

  has_many :friendships

  def getFriends
    friends = []
    self.friendships.each do |friendship|
      if friendship.accepted then
        friends << User.find(friendship.friend_id)
      end
    end
    return friends
  end

  def getFriendRequests
    requests = []
    Friendship.where(friend_id: self.id ).to_a.each do |friendship|
      if !friendship.accepted then
        requests << User.find(friendship.user_id)
      end
    end
    return requests
  end

  def addFriend(friend_id)
    friend = User.find(friend_id)
    friends = self.getFriends
    if !friend.nil? then
      if !friends.include?(friend) then
        self.friendships.create({:friend_id => friend_id, :accepted => true})
      end
      if !friends.include?(self) then
        User.find(friend_id).friendships.create({:friend_id => self.id, :accepted => true})
      end
    end
  end

  #complete if already requested on other side
  def requestFriend(request_id)
    friend = User.find(request_id)
    requests = self.getFriendRequests
    if friend then
      if !requests.include?(friend) then
        self.friendships.create({:friend_id => request_id, :accepted => true})
      end
    end
  end

  def confirmFriendRequest(request_id)
    user = User.find(request_id)
    if user then
      friendships = user.friendships
      if friendships then
        friendship = friendships.find_by_friend_id(self.id)
        if friendship then
          friendship.accepted = true
          user.friends << self
          user.friendships.find_by_friend_id(self.id).accepted = true
        end
      end
    end
  end

  def removeFriend(remove_id)
    friend = User.find(remove_id)
    if friend then
      if self.friends.include?(friend) then
        self.friends.delete(friend)
        self.friendships.find_by_friend_id(friend.id)
      end
      if friend.friends.include?(friend) then
        friend.friends.delete(friend)
        friend.friendships.find_by_friend_id(self.id)
      end
    end
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

  def friends
    @friends = []
    self.superiors.each do |boss|
      @friends << boss
    end
    self.subordinates.each do |underling|
      @friends << underling
    end
    @friends
  end
	def degree
		curr_degree = 0
		curr_degree = curr_degree + self.expertises.size
		return curr_degree
	end

  def self.suggestions(topic, previous_suggestions=[])
    @users = previous_suggestions
    iter = 0

    while ((@users.length < 5) && (iter < 10))do
      @users += User.all.sample(5)
      @users = (@users - topic.experts).uniq
      iter += 1
    end
    @users
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
