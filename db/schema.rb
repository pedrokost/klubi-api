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

ActiveRecord::Schema.define(version: 20150822135854) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "klubs", force: :cascade do |t|
    t.string   "name",          limit: 255,                                          null: false
    t.string   "slug",          limit: 255,                                          null: false
    t.string   "address",       limit: 255
    t.string   "town",          limit: 255
    t.string   "website",       limit: 255
    t.string   "phone",         limit: 255
    t.string   "email",         limit: 255
    t.decimal  "latitude",                  precision: 10, scale: 6
    t.decimal  "longitude",                 precision: 10, scale: 6
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "complete",                                           default: false
    t.string   "categories",                                         default: [],                 array: true
    t.string   "facebook_url",  limit: 255
    t.string   "editor_emails",                                      default: [],                 array: true
    t.integer  "parent_id"
  end

  add_index "klubs", ["categories"], name: "index_klubs_on_categories", using: :gin
  add_index "klubs", ["categories"], name: "klubs_categories", using: :btree
  add_index "klubs", ["editor_emails"], name: "index_klubs_on_editor_emails", using: :gin
  add_index "klubs", ["parent_id"], name: "index_klubs_on_parent_id", using: :btree
  add_index "klubs", ["slug"], name: "index_klubs_on_slug", using: :btree

end
