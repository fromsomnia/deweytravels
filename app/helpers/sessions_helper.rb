module SessionsHelper
  protected
    def authenticate
      authenticate_or_request_with_http_token do |token, options|
        @current_user = User.find_by(auth_token: token)
        if @current_user
          @current_graph = @current_user.graph
        end
        @current_user
      end
    end

    def authenticate_without_401
      auth_header = request.headers['Authorization'].to_s
      token = auth_header[12, auth_header.length-12]
      if token
        @current_user = User.find_by(auth_token: token)
      else
        @current_user = nil
      end
    end
end
