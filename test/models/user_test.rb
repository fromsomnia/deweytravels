require 'test_helper'


class UserTest < ActiveSupport::TestCase
  def get_new_user(user_id)
    new_user = User.new
    new_user.email = user_id.to_s + '.gmail.com'
    new_user.graph = Graph.first
    new_user.first_name = "First Name " + user_id.to_s
    new_user.last_name = "Last Name " + user_id.to_s
    new_user.phone = "123456789"
    return new_user
  end

  def _get_socialcast_users(domain)
    return  [
                {"contact_info"=> {
                                         "office_phone"=> "123456789",
                                         "email"=>"bot@socialcast.com"},
                  "subdomain" => "dewey",
                  "domain" => "dewey.socialcast.com",
                  "custom_fields"=>[],
                  "id"=> 1,
                  "name"=> "Production Bot #145",
                  "avatars"=> { "square16" => "square16", "square30"=> "square30",
                               "square70" => "square70", "square140"=> "square140"},
                  "custom_fields"=> [ { "id"=> "title",
                                        "value"=> "Marketing Coordinator",
                                        "label"=> "Title"} ]
                },
                
                {"contact_info"=> {
                                         "office_phone"=> "123456789",
                                         "email"=>"dummy_email@email.com" },

                  "subdomain" => "dewey",
                  "domain" => "dewey.socialcast.com",
                  "custom_fields"=>[],
                  "id"=> 2,
                  "name"=> "Dummy Person",
                  "avatars"=> { "square16" => "square16", "square30"=> "square30",
                               "square70" => "square70", "square140"=> "square140"},
                  "custom_fields"=> [ { "id"=> "title",
                                        "value"=> "Marketing Coordinator",
                                        "label"=> "Title"} ]
                },
                
            ] 
  end

  test "user_from_sc_user" do
    # Testing that given a dictionary of valid response from socialcast,
    # the users are added correctly
    user = User._user_from_sc_user(_get_socialcast_users("dewey").first, self.get_new_graph("dewey"))
    assert_equal("bot@socialcast.com", user.email)
  end

  def get_new_graph(domain_name)
    new_graph = Graph.new
    new_graph.domain = "dewey"
    new_graph.save
    return new_graph
  end

  test "load_from_sc" do
    Socialcast.any_instance.stubs(:get_users).returns(_get_socialcast_users('dewey'))
    old_num = User.all.length
    new_graph = get_new_graph("dewey")

    sc = Socialcast.new("dummy_email", "dummy_password")
    User.load_from_sc(sc, new_graph)
    assert_equal(old_num + 2, User.all.length)

    users = new_graph.users
    assert_equal(2, users.length)

    # Test that there should not be duplicates if we are reloading
    User.load_from_sc(sc, new_graph)
    assert_equal(old_num + 2, User.all.length)
  end

  test "update_all_domains" do 
    Socialcast.any_instance.stubs(:authenticate).returns({"success" => true})
    Socialcast.any_instance.stubs(:get_users).returns(_get_socialcast_users('dewey'))

    old_num = User.all.length
    Graph.update_all_users_in_all_domains
    assert_equal(old_num + 2, User.all.length)
  end

  test "register_or_login_user" do
    old_num = User.all.length
    Socialcast.any_instance.stubs(:get_users).returns(_get_socialcast_users('dewey'))

    sc = Socialcast.new("dummy_email@email.com", "dummy_password")

    # Test that registering a new user saves the email, password
    # and grab other users in the socialcast instance
    user = User.register_or_login_user(sc, 2, "dewey",
                            "dummy_email@email.com", "dummy_password")

    assert_equal(2, Graph.all.length)
    assert_equal(old_num + 2, User.all.length)
    assert_equal("dummy_password", user.password)
    assert_equal("dummy_email@email.com", user.email)
    
    graph = Graph.find_by_domain("dewey")
    assert graph
    other_user = User.where(:graph_id => graph.id, :sc_user_id => 1).first
    assert other_user

    assert_equal("bot@socialcast.com", other_user.email)

    # Test that logging in a previously saved user does not grab
    # other (duplicate) users in the socialcast instance.

    user = User.register_or_login_user(sc, 2, "dewey",
                            "dummy_email@email.com", "dummy_password")

    assert_equal(old_num + 2, User.all.length)
    assert_equal(2, Graph.all.length)
  end
end
