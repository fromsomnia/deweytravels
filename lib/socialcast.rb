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
        login_auth = {email: @auth[:username], password: @auth[:password]}
        response = self.class.post('/authentication.json', {body: login_auth})
        status = response.parsed_response
        return status
    end

    def get_users
        response = self.class.get('/users.json', {body: {state: 'active'}, basic_auth: @auth})
        return response.parsed_response['users']
    end

    def get_stream
        response = self.class.get('/messages.json', {body: {state: 'active'}, basic_auth: @auth})
        return response.parsed_response
    end
end