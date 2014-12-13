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

ActiveRecord::Schema.define(version: 20141213175601) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "klubs", force: true do |t|
    t.string   "name",                                                  null: false
    t.string   "slug",                                                  null: false
    t.string   "address"
    t.string   "town"
    t.string   "website"
    t.string   "phone"
    t.string   "email"
    t.string   "editor_email"
    t.decimal  "latitude",     precision: 10, scale: 6
    t.decimal  "longitude",    precision: 10, scale: 6
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "complete",                              default: false
    t.string   "categories",                            default: [],                 array: true
    t.string   "facebook_url"
  end

  add_index "klubs", ["categories"], name: "index_klubs_on_categories", using: :gin
  add_index "klubs", ["slug"], name: "index_klubs_on_slug", using: :btree

end
