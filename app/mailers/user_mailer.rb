class UserMailer < ActionMailer::Base
  default from: "info@deweytravels.com"
  def welcome_email (user)
    @user = user
    @login_url = "http://www.deweytravels.com"
    mail(to: @user.email, subject: "Welcome to Dewey!")
  end

end
