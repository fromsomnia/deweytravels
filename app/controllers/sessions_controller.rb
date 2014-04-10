require 'socialcast'
require 'pp'

class SessionController < ApplicationController
  def login
  end

  def post_login
    email = params[:email]
    password = params[:password]
    sc = Socialcast.new(email, password)
    status = sc.authenticate

    if status['authentication-failure']
      err = status['authentication-failure']
      render json: err, status: :unauthorized
    else
      # TODO: figure out what to do if login belongs to > 1 community
      info = status['communities'][0]
      domain = info['subdomain']
      sc_user_id = info['profile']['id']
      
      @user = User.register_or_login_user(sc, sc_user_id, domain, email, password)

      if @user
        sign_in @user
      end

      head :ok
    end
  end

  def logout
    sign_out
  end
end
