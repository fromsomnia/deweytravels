require 'socialcast'
class User < ActiveRecord::Base
	attr_accessible :sc_user_id, :first_name, :last_name, :domain, :email, :phone, :username, :password, :position, :department, :image
  before_create :set_auth_token

  belongs_to :graph

	has_many :topic_user_connections, :foreign_key => "expert_id"
	has_many :expertises, -> { uniq }, :through => :topic_user_connections, :source => :expertise

	has_many :user_user_connections, :foreign_key => "superior_id"
	has_many :second_user_user_connections, :class_name => "UserUserConnection", :foreign_key => "subordinate_id"

	has_many :subordinates, :through => :user_user_connections, :source => :subordinate
	has_many :superiors, :through => :second_user_user_connections, :source => :superior

  has_many :user_action_votes, :foreign_key => "action_id"
  has_many :upvoted_actions, :through => :user_action_votes, :source => :action

  def self.register_google_user(first_name, last_name, email, password, image_url,
                                goog_access_token, goog_expires_time)

    graph = Graph.find_by_domain('google.com')
    if not graph
      graph = Graph.new
      graph.domain = 'google.com'
      graph.save
    end

    new_user = User.new
    new_user.first_name = first_name
    new_user.last_name = last_name
    new_user.graph = graph
    new_user.email = email
    new_user.password = password
    # TODO(veni): uncomment when we change image to image_url
    # new_user.image_url = image_url
    new_user.goog_access_token = goog_access_token
    new_user.goog_expires_time = goog_expires_time
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


  # Returns a Dewey user instance from a Socialcast user instance
  def self._user_from_sc_user(sc_user, graph)
    new_user = User.where(:sc_user_id => sc_user['id'], :graph_id => graph.id).first
    if (!new_user)
      new_user = new
    end
    new_user.sc_user_id = sc_user['id']
    new_user.email = sc_user['contact_info']['email']
    new_user.graph = graph
    names = sc_user['name'].split
    new_user.first_name = names[0]
    new_user.last_name = names[1]
    new_user.image_16 = sc_user['avatars']['square16']
    new_user.image_30 = sc_user['avatars']['square30']
    new_user.image_70 = sc_user['avatars']['square70']
    new_user.image_140 = sc_user['avatars']['square140']
    new_user.phone = sc_user['contact_info']['office_phone']
  
    sc_user['custom_fields'].each do |field|
      if field['id'] == 'title'
        new_user.title = field['value']
      end
    end
    return new_user
  end

  # TODO(brett): should probably optimize with bulk insertion
  def self.load_from_sc(sc, graph)
    if sc
      sc_users = sc.get_users
      sc_users.each do |sc_user|
        new_user = User._user_from_sc_user(sc_user, graph)
        if not new_user
          return false
        end
        new_user.save
      end
    else
      return false
    end
    return true
  end

  def self.register_or_login_user(sc, sc_user_id, domain, email, password)
    if not Graph.find_by_domain(domain)
      # TODO: This should move to background process at some point.
      graph = Graph.new
      graph.domain = domain
      graph.save

      # TODO: move to bg process
      load_from_sc(sc, graph)
    else
      graph = Graph.find_by_domain(domain)
    end

    user = User.where(:graph_id => graph.id, :sc_user_id => sc_user_id).first
    user.email = email
    user.password = password
    return user
  end

  private
    def set_auth_token
      return if auth_token.present?

      begin
        self.auth_token = SecureRandom.hex
      end while self.class.exists?(auth_token: self.auth_token)
    end
end
