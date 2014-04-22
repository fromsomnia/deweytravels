class UserMailer < ActionMailer::Base
  default from: "from@example.com"
  def welcome_email (user)
    @user = user
    @login_url = "http://team-dewey-website.herokuapp.com/dev/"
    mail(to: @user.email, subject: "Welcome to Dewey!")
  end

end
