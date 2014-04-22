require 'socialcast'
require 'pp'

class SessionsController < ApplicationController
  before_action :authenticate, only: [:get_auth_token]

  def get_auth_token
    render json: {:auth_token => @current_user.auth_token}, status: :ok
  end

  def login
  end

  def google_api
    if (Rails.env == "development")
      render json: {:client_id => '592878661111-b53keflh2nk0q6eipf965c7srutnllr0.apps.googleusercontent.com'}
    elsif (Rails.env == "production")
      render json: {:client_id => '1091102339818-6bbfsv82rj0rt81s00q2t2gcfsiuntd3.apps.googleusercontent.com'}
    end
    return
  end

  def post_try_google_login
    email = params[:email]
    @user = User.find_by_email(email)
    if @user
      render json: {:auth_token => @user.auth_token}, status: :ok
    else
      render json: {}, :status => :unauthorized
    end
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
      puts ("found a user")
      render json: {:auth_token => @user.auth_token}, status: :ok
      return
    end

    if !goog_access_token.empty? and !goog_expires_time.empty?
      puts ("google")
      @user = User.register_google_user(first_name, last_name,
                                email, password, image_url,
                                goog_access_token, goog_expires_time)
      UserMailer.delay.welcome_email(@user)
      render json: {:auth_token => @user.auth_token}, status: :ok
      return
    end

    # # don't need anymore since we aren't using socialcast login
    # sc = Socialcast.new(email, password)
    # status = sc.authenticate

    # if status['authentication-failure']
    #   err = status['authentication-failure']
    #   render json: err, status: :unauthorized
    # else
    #   # TODO: figure out what to do if login belongs to > 1 community
    #   info = status['communities'][0]
    #   domain = info['subdomain']
    #   sc_user_id = info['profile']['id']
      
    #   @user = User.register_or_login_user(sc, sc_user_id, domain, email, password)
    #   UserMailer.delay.welcome_email(@user)
    #   render json: {:auth_token => @user.auth_token}, status: :ok
    # end
  end

  def register
    first_name = params[:first_name]
    last_name = params[:last_name]
    email = params[:email]
    password = params[:password]
    @user = User.register_dewey_user(first_name, last_name, email, password)
    if @user
      render json: {:auth_token => @user.auth_token}, status: :ok
      return
    end
  end

  def logout
    sign_out
  end
end
