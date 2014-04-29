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

  def post_facebook_login
    id = params[:id]
    first_name = params[:first_name]
    last_name = params[:last_name]
    image_url = params[:image_url]
    @user = User.find_by_sc_user_id(id)
    if !@user
      @user = User.register_facebook_user(id, first_name, last_name, image_url)
    end
    render json: {:auth_token => @user.auth_token}, status: :ok
    return
  end

  def logout
    sign_out
  end
end
