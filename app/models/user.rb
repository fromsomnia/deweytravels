class User < ActiveRecord::Base
	attr_accessible :first_name, :last_name, :domain, :email, :username, :password, :position, :department, :image

	has_many :topic_user_connections, :foreign_key => "expert_id"
	has_many :expertises, :through => :topic_user_connections, :source => :expertise

	has_many :user_user_connections, :foreign_key => "superior_id"
	has_many :second_user_user_connections, :class_name => "UserUserConnection", :foreign_key => "subordinate_id"

	has_many :subordinates, :through => :user_user_connections, :source => :subordinate
	has_many :superiors, :through => :second_user_user_connections, :source => :superior

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

    #TODO: should probably optimize with bulk insertion
    def self.load_from_sc(sc, domain)
        if sc
          puts "logged in"
          users = sc.get_users
          users.each do |user|
              pp user
              new_user = new
              new_user.user_id = user['id']
              new_user.email = user['contact_info']['email']
              new_user.domain = domain
              names = user['name'].split
              new_user.first_name = names[0]
              new_user.last_name = names[1]
              new_user.image_16 = user['avatars']['square16']
              new_user.image_30 = user['avatars']['square30']
              new_user.image_70 = user['avatars']['square70']
              new_user.image_140 = user['avatars']['square140']
              new_user.office_phone = user['contact_info']['office-phone']
              user['custom_fields'].each do |field|
                if field['id'] == 'title'
                  new_user.title = field['value']
                end
              end
              puts new_user
              new_user.save
          end
        else
          puts "not logged in"
          return false
        end
        return true
    end
end
