#This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110222051358) do

  create_table "cached_feeds", :force => true do |t|
    t.string   "href"
    t.string   "title"
    t.string   "link"
    t.text     "feed_data"
    t.string   "feed_data_type"
    t.text     "http_headers"
    t.datetime "last_retrieved"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "fname"
    t.string   "lname"
    t.string   "password"
    t.string   "address"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.string   "gender",                    :limit => 1
    t.boolean  "status"
    t.binary   "file"
    t.string   "filename"
    t.string   "permalink"
    t.string   "dob"
    t.string   "description"
  end

end
