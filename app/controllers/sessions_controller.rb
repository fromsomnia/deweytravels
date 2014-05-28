require 'socialcast'
require 'pp'

class SessionsController < ApplicationController
  before_action :authenticate_without_401, only: [:get_auth_token]

  def mixpanel_id
    if (Rails.env == "development")
      render json: {:mixpanel_id => "1b59612a39ff701927e1df658130eb88" }, status: :ok
    else
      render json: {:mixpanel_id => "1dab72d89b67a9cdbea1cb8292f2d554" }, status: :ok
    end
  end

  def get_auth_token
    render json: {:uid => @current_user.id,
                  :auth_token => @current_user.auth_token}, status: :ok
  end

  def login
  end

  def post_try_facebook_login
    id = params[:id]
    @user = User.find_by_fb_id(id)
    if @user and @user.is_registered
      render json: {:auth_token => @user.auth_token, :uid => @user.id}, status: :ok
    else
      render json: {}, status: :not_authorized
    end

  end

  def post_facebook_login
    id = params[:id]
    first_name = params[:first_name]
    last_name = params[:last_name]
    email = params[:email]
    image_url = params[:image_url]
    accessToken = params[:access_token]
    friends = params[:friends]
    locations = params[:locations]
    @user = User.find_by_fb_id(id)
    if !@user
      @user = User.register_facebook_user(id, first_name, last_name, email, image_url)
    end
    @user.is_registered = true
    @user.save
    render json: {:auth_token => @user.auth_token,
                  :uid => @user.id}, status: :ok
    return
  end

  def logout
    sign_out
  end
end
