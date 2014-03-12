require 'test_helper'


class UserTest < ActiveSupport::TestCase
  # test "all users" do
  # 	puts "Displaying All User Information..."
  # 	puts ""
  # 	User.all.each do |user|
  # 		puts "USER ================= " + user.first_name + " =================="

  # 		puts " First Name: " + user.first_name
  # 		puts " Last Name: " + user.last_name
  # 		puts " Email: " + user.email
  # 		puts " Username: " + user.username
  # 		puts " Password: " + user.password
  # 		puts " Position: " + user.position
  # 		puts " Department: " + user.department
  # 		puts " Image: " + user.image

  # 		puts ""
  # 		puts " " + user.first_name + "'s Superiors:"
  # 		user.superiors.each do |superior|
  # 			puts "    " + superior.first_name + " " + superior.last_name
  # 		end

  # 		puts ""
  # 		puts " " + user.first_name + "'s Peers:"
  # 		user.peers.each do |peer|
  # 			puts "    " + peer.first_name + " " + peer.last_name
  # 		end

  # 		puts ""
  # 		puts " " + user.first_name + "'s Subordinates:"
  # 		user.subordinates.each do |subordinate|
  # 			puts "    " + subordinate.first_name + " " + subordinate.last_name
  # 		end

  # 		puts ""
  # 		puts " " + user.first_name + "'s Expertise: (Skill: " + user.expertises.size.to_s + ")"
  # 		user.expertises.each do |expertise|
  # 			puts "    " + expertise.title
  # 		end

  # 		puts "======================================="
  # 		puts ""
  # 		puts ""
  # 	end
  # 	assert true
  # end

  def get_new_user(user_id)
    new_user = User.new
    new_user.email = user_id.to_s + '.gmail.com'
    new_user.domain = "default_domain"
    new_user.first_name = "First Name " + user_id.to_s
    new_user.last_name = "Last Name " + user_id.to_s
    new_user.phone = "123456789"
    return new_user
  end

  test "get_domains" do
    domains = User.domains
    assert_equal(1, domains.length)
    assert_equal("dewey-cs210", domains[0])
   
    new_user = get_new_user(1)
    new_user.save
 
    domains = User.domains
    assert_equal(2, domains.length)
    assert_equal(Set.new(["dewey-cs210", "default_domain"]),
                 domains.to_set())
  end

  def _get_socialcast_users(domain)
    return  [
                {"contact_info"=> {
                                         "office_phone"=> "123456789",
                                         "email"=>"bot@socialcast.com"},
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
    user = User._user_from_sc_user(_get_socialcast_users("dewey").first,"dewey")
    assert_equal("bot@socialcast.com", user.email)
  end

  test "load_from_sc" do
    Socialcast.any_instance.stubs(:get_users).returns(_get_socialcast_users('dewey'))
    old_num = User.all.length
    sc = Socialcast.new("dummy_email", "dummy_password")
    User.load_from_sc(sc, "dewey")
    assert_equal(old_num + 2, User.all.length)

    user1 = User.where(:domain => "dewey", :sc_user_id => 1).first
    user2 = User.where(:domain => "dewey", :sc_user_id => 2).first
    user3 = User.where(:domain => "dewey", :sc_user_id => 3).first
    assert user1
    assert user2
    assert !user3
  end

  test "register_or_login_user" do
    old_num = User.all.length
    Socialcast.any_instance.stubs(:get_users).returns(_get_socialcast_users('dewey'))

    sc = Socialcast.new("dummy_email@email.com", "dummy_password")

    # Test that registering a new user saves the email, password
    # and grab other users in the socialcast instance
    user = User.register_or_login_user(sc, 2, "dewey",
                            "dummy_email@email.com", "dummy_password")

    assert_equal(old_num + 2, User.all.length)
    assert_equal("dummy_password", user.password)
    assert_equal("dummy_email@email.com", user.email)
    
    other_user = User.where(:domain => "dewey", :sc_user_id => 1).first
    assert other_user

    assert_equal("bot@socialcast.com", other_user.email)

    # Test that logging in a previously saved user does not grab
    # other (duplicate) users in the socialcast instance.

    user = User.register_or_login_user(sc, 2, "dewey",
                            "dummy_email@email.com", "dummy_password")

    assert_equal(old_num + 2, User.all.length)
  end
end
