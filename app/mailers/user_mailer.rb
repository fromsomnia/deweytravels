class UserMailer < ActionMailer::Base
  default from: "info@deweytravels.com"
  def welcome_email(user)
    @user = user
    @login_url = "http://www.deweytravels.com"
    mail(to: @user.email, subject: "Welcome to Dewey!")
  end

  def weekly_email(user, friends=[])
    @user = user
    @suggestions = Topic.suggestions(user = user)

    @user_url = "http://www.deweytravels.com"
    if friends == []
      @friends = user.friends_on_site
    else
      @friends = friends
    end
    mail(to: user.email, subject: "This week on DeweyTravels")
  end
end
