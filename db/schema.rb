# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_10_31_152650) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "update_status", ["unverified", "accepted", "rejected"]

  create_table "comment_requests", force: :cascade do |t|
    t.string "commentable_type"
    t.bigint "commentable_id"
    t.string "requester_email"
    t.string "requester_name"
    t.string "commenter_email"
    t.string "commenter_name"
    t.string "request_hash"
    t.bigint "comment_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["comment_id"], name: "index_comment_requests_on_comment_id"
    t.index ["commentable_type", "commentable_id", "commenter_email"], name: "index_comment_request_unique_commenter_commentable", unique: true
    t.index ["commentable_type", "commentable_id"], name: "index_comment_requests_on_commentable_type_and_commentable_id"
    t.index ["request_hash"], name: "index_comment_requests_on_request_hash"
  end

  create_table "comments", force: :cascade do |t|
    t.string "commentable_type"
    t.bigint "commentable_id"
    t.string "body"
    t.string "commenter_email"
    t.string "commenter_name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "email_stats", id: :serial, force: :cascade do |t|
    t.string "email", null: false
    t.datetime "last_opened_at", precision: nil
    t.datetime "last_clicked_at", precision: nil
    t.datetime "last_bounced_at", precision: nil
    t.datetime "last_dropped_at", precision: nil
    t.datetime "last_delivered_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["email"], name: "index_email_stats_on_email", unique: true
  end

  create_table "klubs", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "slug", limit: 255, null: false
    t.string "address", limit: 255
    t.string "town", limit: 255
    t.string "website", limit: 255
    t.string "phone", limit: 255
    t.string "email", limit: 255
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "complete", default: false
    t.string "categories", limit: 255, default: [], array: true
    t.string "facebook_url", limit: 255
    t.string "editor_emails", limit: 255, default: [], array: true
    t.integer "parent_id"
    t.boolean "verified", default: false
    t.string "notes"
    t.datetime "last_verification_reminder_at", precision: nil
    t.date "closed_at"
    t.string "description"
    t.integer "visits_count", default: 0
    t.datetime "visits_count_updated_at", precision: nil
    t.datetime "data_confirmed_at", precision: nil
    t.string "data_confirmation_request_hash"
    t.index "st_geographyfromtext((((('SRID=4326;POINT('::text || longitude) || ' '::text) || latitude) || ')'::text))", name: "index_on_klubs_location", using: :gist
    t.index ["categories"], name: "index_klubs_on_categories", using: :gin
    t.index ["editor_emails"], name: "index_klubs_on_editor_emails", using: :gin
    t.index ["parent_id"], name: "index_klubs_on_parent_id"
    t.index ["slug"], name: "index_klubs_on_slug"
  end

  create_table "obcinas", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.integer "population_size"
    t.geography "geom", limit: {:srid=>4326, :type=>"multi_polygon", :geographic=>true}
    t.integer "statisticna_regija_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["geom"], name: "index_obcinas_on_geom", using: :gist
    t.index ["slug"], name: "index_obcinas_on_slug", unique: true
    t.index ["statisticna_regija_id"], name: "index_obcinas_on_statisticna_regija_id"
  end

  create_table "statisticna_regijas", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.integer "population_size"
    t.geography "geom", limit: {:srid=>4326, :type=>"multi_polygon", :geographic=>true}
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["geom"], name: "index_statisticna_regijas_on_geom", using: :gist
    t.index ["slug"], name: "index_statisticna_regijas_on_slug", unique: true
  end

  create_table "updates", id: :serial, force: :cascade do |t|
    t.string "updatable_type", null: false
    t.integer "updatable_id", null: false
    t.string "field", null: false
    t.string "oldvalue"
    t.string "newvalue"
    t.enum "status", default: "unverified", enum_type: "update_status"
    t.string "editor_email"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "acceptance_email_sent", default: false
    t.index ["status"], name: "index_updates_on_status"
    t.index ["updatable_id"], name: "index_updates_on_updatable_id"
    t.index ["updatable_type"], name: "index_updates_on_updatable_type"
  end

  add_foreign_key "obcinas", "statisticna_regijas"
end
