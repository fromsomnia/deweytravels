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
      #TODO: figure out what to do if login belongs to > 1 community
      info = status['communities'][0]
      domain = info['subdomain']
      user_id = info['profile']['id']
      #if company is not in db, fetch all employees:
      if !User.exists?(domain: domain)
        puts "fetching all users"
        User.load_from_sc(sc, domain)
      end
      #TODO: just using user id as auth token for now - should change
      session[:user_id] = user_id
      head :ok
    end
  end

  def logout
    session[:user] = nil
  end
end
