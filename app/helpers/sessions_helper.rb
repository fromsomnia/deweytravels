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
end
