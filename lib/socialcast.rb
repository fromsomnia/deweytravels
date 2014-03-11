class Socialcast
    include HTTParty
    debug_output $stdout
    
    #TODO: don't hard code domain once switched to OAUTH
    domain_name = 'dewey-cs210'
    base_uri "https://#{domain_name}.socialcast.com/api"
    format :json
    def initialize(username, password)
        @auth = {:username => username, :password => password}
    end

    def authenticate
        puts "posting login"
        login_auth = {email: @auth[:username], password: @auth[:password]}
        puts login_auth
        response = self.class.post('/authentication.json', {body: login_auth})
        puts response
        status = response.parsed_response
        return response.parsed_response
    end

    def get_users
        puts "getting users"
        response = self.class.get('/users.json', {body: {state: 'active'}, basic_auth: @auth})
        return response.parsed_response['users']
    end
end