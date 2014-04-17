class Socialcast
    include HTTParty
    
    #TODO: don't hard code domain once switched to OAUTH
    domain_name = 'dewey-cs210'
    base_uri "https://#{domain_name}.socialcast.com/api"
    format :json
    def initialize(username, password)
        @auth = {:username => username, :password => password}
    end

    def authenticate
        puts "login: posting..."
        login_auth = {email: @auth[:username], password: @auth[:password]}
        #puts login_auth
        response = self.class.post('/authentication.json', {body: login_auth})
        #puts response
        puts "login: finished"
        status = response.parsed_response
        return status
    end

    def get_users
        puts "getting users..."
        response = self.class.get('/users.json', {body: {state: 'active'}, basic_auth: @auth})
        puts "getting users: finished"
        return response.parsed_response['users']
    end

    def get_stream
        puts "getting stream messages...."
        response = self.class.get('/messages.json', {body: {state: 'active'}, basic_auth: @auth})
        puts "getting stream messages: finished"
        return response.parsed_response
    end
end