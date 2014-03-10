require 'socialcast'

class SessionController < ApplicationController
  def login
  end

  def post_login
    email = params[:email]
    password = params[:password]
    sc = Socialcast.new(email, password)
    status = sc.post_login
    #need to check that login success
    if status['authentication-failure']
      puts "Could not log in"
      puts status['authentication-failure']['error-message']

      #handle error
      #LOGIN ERROR
      #status['authentication-failure']['error-code']
      #status['authentication-failure']['error-message']
    else
    #temp hack storing auth info in client session until we have oauth *cringe*
      session[:user] = sc
      domain = status['communities'][0]['subdomain']
      puts domain
      #if can't find domain in Users:
      unless User.exists? domain: domain
        puts "fetching all users"
        get_users
      end
    end
      render json: status
  end

  def get_users
    email = params[:email]
    password = params[:password]
    sc = session[:user]
    if sc
      puts "logged in"
      users = sc.get_users
      users.each do |user|
          User.new
          email = user['contact_info']['email']
          name = user['name']
          puts email
          puts name
      end
    else
      puts "not logged in"
      # render json: {error: 'not logged in'}
    end
  end

  def logout
    session[:user] = nil
  end
end
