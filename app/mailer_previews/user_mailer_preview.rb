class UserMailerPreview
  def welcome_email
    UserMailer.welcome_email mock_user
  end

  def weekly_email
    @friends = User.all.sample(5)
    UserMailer.weekly_email(User.find_by_email('angelina.veni@gmail.com'), @friends)
  end

  private

    def mock_user
      fake_id User.new(first_name: 'Jack', last_name: 'Nicholson')
    end

    def fake_id(obj)
      obj.define_singleton_method(:id) { 123 + rand(100) }
      obj
    end
end
