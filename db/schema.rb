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

ActiveRecord::Schema.define(version: 20140416074119) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actions", force: true do |t|
    t.integer  "table_pkey"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "graphs", force: true do |t|
    t.string "domain"
  end

  add_index "graphs", ["domain"], name: "index_graphs_on_domain", unique: true, using: :btree

  create_table "networks", force: true do |t|
    t.string "domain"
  end

  create_table "topic_topic_connections", force: true do |t|
    t.integer "subtopic_id"
    t.integer "supertopic_id"
    t.integer "action_id"
  end

  create_table "topic_user_connections", force: true do |t|
    t.integer "expert_id"
    t.integer "expertise_id"
  end

  create_table "topics", force: true do |t|
    t.string  "title"
    t.string  "freebase_image_url"
    t.string  "freebase_topic_id"
    t.integer "graph_id"
  end

  add_index "topics", ["graph_id", "title"], name: "index_topics_on_graph_id_and_title", unique: true, using: :btree
  add_index "topics", ["graph_id"], name: "index_topics_on_graph_id", using: :btree

  create_table "user_action_votes", force: true do |t|
    t.integer  "action_id"
    t.integer  "user_id"
    t.integer  "vote_value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_user_connections", force: true do |t|
    t.integer "superior_id"
    t.integer "subordinate_id"
  end

  create_table "users", force: true do |t|
    t.string  "first_name"
    t.string  "last_name"
    t.string  "email"
    t.string  "phone"
    t.string  "username"
    t.string  "password"
    t.string  "position"
    t.string  "department"
    t.string  "image_url"
    t.string  "title"
    t.integer "sc_user_id"
    t.integer "graph_id"
    t.string  "auth_token"
    t.string  "goog_access_token"
    t.integer "goog_expires_time", limit: 8
  end

  add_index "users", ["auth_token"], name: "index_users_on_auth_token", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["graph_id"], name: "index_users_on_graph_id", using: :btree

end
