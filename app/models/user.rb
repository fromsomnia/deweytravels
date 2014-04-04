require 'socialcast'
class User < ActiveRecord::Base
	attr_accessible :sc_user_id, :first_name, :last_name, :domain, :email, :phone, :username, :password, :position, :department, :image

	has_many :topic_user_connections, :foreign_key => "expert_id"
	has_many :expertises, :through => :topic_user_connections, :source => :expertise, :uniq => true

	has_many :user_user_connections, :foreign_key => "superior_id"
	has_many :second_user_user_connections, :class_name => "UserUserConnection", :foreign_key => "subordinate_id"

	has_many :subordinates, :through => :user_user_connections, :source => :subordinate
	has_many :superiors, :through => :second_user_user_connections, :source => :superior

  has_many :user_action_votes, :foreign_key => "action_id"
  has_many :upvoted_actions, :through => :user_action_votes, :source => :action

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

  # Returns all existing Socialcast domains on the app
  def self.domains
    return User.select("DISTINCT domain").map(&:domain)
  end

  # Update the Socialcast info of all users in all the Socialcast instances
  # in our system. Also pulled in and save Socialcast users that are not
  # part of the site.

  def self.update_all_domains
    User.domains.each do |domain|
      users = User.where(:domain => domain)
      users.each do |user|
        sc = Socialcast.new(user.email, user.password)
        status = sc.authenticate
        if !status['authentication-failure']
          if (User.load_from_sc(sc, user.domain))
            break
          end
        end
      end
    end
  end

  # Returns a Dewey user instance from a Socialcast user instance
  def self._user_from_sc_user(sc_user, domain)
    new_user = User.where(:sc_user_id => sc_user['id']).first
    if (!new_user)
      new_user = new
    end
    new_user.sc_user_id = sc_user['id']
    new_user.email = sc_user['contact_info']['email']
    new_user.domain = domain
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
  def self.load_from_sc(sc, domain)
    if sc
      sc_users = sc.get_users
      sc_users.each do |sc_user|
        new_user = User._user_from_sc_user(sc_user, domain)
        new_user.save
      end
    else
      return false
    end
    return true
  end

  def self.register_or_login_user(sc, sc_user_id, domain, email, password)
    # If company is not in db, fetch all employees:
    if !User.exists?(domain: domain)
      # TODO: This should move to background process at some point.
      load_from_sc(sc, domain)
    end

    user = User.where(:domain => domain, :sc_user_id => sc_user_id).first
    user.email = email
    user.password = password
    return user
  end

end
