class UserMailerPreview
  def welcome_email
    UserMailer.welcome_email mock_user
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
