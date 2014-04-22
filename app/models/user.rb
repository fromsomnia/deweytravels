require 'socialcast'

class User < ActiveRecord::Base
	attr_accessible :sc_user_id, :first_name, :last_name, :domain, :email, :phone, :username, :password, :position, :department, :image_url
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

  def self.import_google_contacts(contacts)
    contacts.each do |contact|
      # This is a dumb heuristic to filter out
      # bad contacts.
      if (contact['title'].split.size == 2) && (contact['email'].include?('@'))
        user = User.find_by_email(contact['email'])
        if not user
          user = User.new
          contact['title'] = contact['title'].titleize
          user.first_name = contact['title'].split[0]
          user.last_name = contact['title'].split[1]
          user.email = contact['email']
          user.graph = Graph.find_by_domain('google.com')
          user.save
        end
      end
    end
  end

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
    new_user.image_url = image_url
    new_user.goog_access_token = goog_access_token
    new_user.goog_expires_time = goog_expires_time
    new_user.save
    return new_user
  end

  def self.register_dewey_user(first_name, last_name, email, password)
    new_user = User.where(:email => email)
    if(new_user)
      # TODO: error, email already in use

    end
    new_user = User.new
    new_user.first_name = first_name
    new_user.last_name = last_name
    new_user.email = email
    new_user.password = password
    new_user.save

    return user
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
    print sc_user['avatars']['square30']
    new_user.image_url = sc_user['avatars']['square30']
  
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

    def set_image_url
      return if image_url.present?

      begin
        self.image_url = '/assets/default_user_image.png'
      end
    end
end
