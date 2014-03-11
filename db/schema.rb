# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140311132448) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "graphs", force: true do |t|
    t.string "title"
  end

  create_table "graphs_topics", id: false, force: true do |t|
    t.integer "graph_id"
    t.integer "topic_id"
  end

  create_table "topic_topic_connections", force: true do |t|
    t.integer "subtopic_id"
    t.integer "supertopic_id"
  end

  create_table "topic_user_connections", force: true do |t|
    t.integer "expert_id"
    t.integer "expertise_id"
  end

  create_table "topics", force: true do |t|
    t.string "title"
  end

  create_table "user_user_connections", force: true do |t|
    t.integer "superior_id"
    t.integer "subordinate_id"
  end

  create_table "users", force: true do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "domain"
    t.string "email"
    t.string "phone"
    t.string "username"
    t.string "password"
    t.string "position"
    t.string "department"
    t.string "image_16"
    t.string "image_30"
    t.string "image_70"
    t.string "image_140"
    t.string "image"
  end

end
