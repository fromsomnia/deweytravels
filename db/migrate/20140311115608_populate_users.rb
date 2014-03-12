# encoding: UTF-8

class PopulateUsers < ActiveRecord::Migration
  def change
	william = User.new(
	 :first_name => "William",
	 :last_name => "Chidyausiku",
	 :email => "wchid@stanford.edu",
	 :username => "william",
	 :password => "william",
	 :position => "Engineer",
	 :phone => "123-456-7890",
	 :department => "Engineering",
	 :image => "William.png")
	william.save(:validate => false)

	veni = User.new(
	 :first_name => "Veni",
	 :last_name => "Johanna",
	 :email => "veni@stanford.edu",
	 :username => "veni",
	 :password => "veni",
	 :position => "Engineer",
	 :department => "Engineering",
	 :phone => "123-456-7890",
	 :image => "Veni.png")
	veni.save(:validate => false)

	brett = User.new(
	 :first_name => "Brett",
	 :last_name => "Solow",
	 :email => "besolow@stanford.edu",
	 :username => "brett",
	 :password => "brett",
	 :position => "Engineer",
	 :department => "Engineering",
	 :phone => "123-456-7890",
	 :image => "Brett.png")
	brett.save(:validate => false)

	stephen = User.new(
	 :first_name => "Stephen",
	 :last_name => "Quiñónez",
	 :email => "stephenq@stanford.edu",
	 :username => "stephen",
	 :password => "stephen",
	 :position => "Engineer",
	 :department => "Engineering",
	 :phone => "123-456-7890",
	 :image => "Stephen.png")
	stephen.save(:validate => false) 

	john = User.new(
	 :first_name => "John",
	 :last_name => "Pulvera",
	 :email => "jpulvera@stanford.edu",
	 :username => "john",
	 :password => "john",
	 :position => "Engineer",
	 :department => "Engineering",
	 :phone => "123-456-7890",
	 :image => "John.png")
	john.save(:validate => false)

	jay = User.new(
	 :first_name => "Jay",
	 :last_name => "Borenstein",
	 :email => "borenstein@cs.stanford.edu",
	 :username => "jay",
	 :password => "jay",
	 :position => "CEO",
	 :department => "Marketing",
	 :phone => "123-456-7890",
	 :image => "default_user_image.png")
	 jay.save(:validate => false)

	chris = User.new(
	 :first_name => "Chris",
	 :last_name => "Surowiec",
	 :email => "csurowiec_99@yahoo.com",
	 :username => "chris",
	 :password => "chris",
	 :position => "VP of Sales",
	 :department => "Sales",
	 :phone => "123-456-7890",
	 :image => "default_user_image.png")
	chris.save(:validate => false)

	oren = User.new(
	 :first_name => "Oren",
	 :last_name => "Root",
	 :email => "oroot@vmware.com",
	 :username => "oren",
	 :password => "oren",
	 :position => "Manager of HR",
	 :department => "Human Resources",
	 :phone => "123-456-7890",
	 :image => "default_user_image.png")
	oren.save(:validate => false)

	marc = User.new(
	 :first_name => "Marc",
	 :last_name => "Fenner",
	 :email => "mfenner@vmware.com",
	 :username => "marc",
	 :password => "marc",
	 :position => "Engineer",
	 :department => "Engineering",
	 :phone => "123-456-7890",
	 :image => "default_user_image.png")
	marc.save(:validate => false)


	mike = User.new(
	 :first_name => "Mike",
	 :last_name => "Louie",
	 :email => "mlouie@vmware.com",
	 :username => "mike",
	 :password => "mike",
	 :position => "Engineer",
	 :department => "Engineering",
	 :phone => "123-456-7890",
	 :image => "default_user_image.png")
	mike.save(:validate => false)
  end
end
