require 'socialcast'
require 'pp'

class SessionsController < ApplicationController
  before_action :authenticate, only: [:get_auth_token]

  def get_auth_token
    render json: {:auth_token => @current_user.auth_token}, status: :ok
  end

  def login
  end

  def post_facebook_login
    id = params[:id]
    first_name = params[:first_name]
    last_name = params[:last_name]
    email = params[:email]
    image_url = params[:image_url]
    @user = User.find_by_fb_id(id)
    if !@user
      @user = User.register_facebook_user(id, first_name, last_name, email, image_url)
    end
    render json: {:auth_token => @user.auth_token}, status: :ok
    return
  end

  def logout
    sign_out
  end
end
