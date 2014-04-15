require 'socialcast'
require 'pp'

class SessionsController < ApplicationController
  def login
  end

  def post_login
    email = params[:email]
    password = params[:password]
    first_name = params[:first_name]
    last_name = params[:last_name]
    goog_access_token = params[:goog_access_token]
    goog_expires_time = params[:goog_expires_time]
    image_url = params[:image_url]

    @user = User.find_by_email_and_password(email, password)
    if @user
      render json: {:auth_token => @user.auth_token}, status: :ok
      return
    end

    if goog_access_token and goog_expires_time
      @user = User.register_google_user(first_name, last_name,
                                email, password,
                                goog_access_token, goog_expires_time,
                                image_url)

      render json: {:auth_token => @user.auth_token}, status: :ok
      return
    end

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

      render json: {:auth_token => @user.auth_token}, status: :ok
    end
  end

  def logout
    sign_out
  end
end
