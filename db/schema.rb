# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_06_17_115433) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cities", force: :cascade do |t|
    t.integer "city_code"
    t.string "name"
    t.string "spell"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "prefecture_code"
    t.string "lg_code"
  end

  create_table "events", force: :cascade do |t|
    t.string "host_id"
    t.string "name"
    t.string "comment"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "group_id", null: false
    t.string "video_chat_room_id"
    t.datetime "start_date_time"
    t.datetime "end_date_time"
    t.index ["group_id"], name: "index_events_on_group_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "image_url"
    t.string "name"
    t.text "introduction"
    t.integer "frequency_times"
    t.integer "max_age"
    t.integer "min_age"
    t.integer "max_number"
    t.boolean "is_same_sexuality"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "host_id"
    t.integer "prefecture_code"
    t.integer "city_code"
    t.boolean "is_online"
    t.integer "group_type"
    t.integer "facility_environment"
    t.integer "frequency_basis"
    t.integer "style"
  end

  create_table "participations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["group_id"], name: "index_participations_on_group_id"
    t.index ["user_id"], name: "index_participations_on_user_id"
  end

  create_table "places", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.float "latitude"
    t.float "longitude"
    t.string "place_id"
    t.string "place_type"
    t.string "global_code"
    t.string "compound_code"
    t.string "url"
    t.text "memo"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "event_id"
    t.index ["event_id"], name: "index_places_on_event_id"
  end

  create_table "prefectures", force: :cascade do |t|
    t.integer "prefecture_code"
    t.string "name"
    t.string "spell"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "capital_name"
    t.string "capital_spell"
    t.float "capital_latitude"
    t.float "capital_longitude"
  end

  create_table "registrations", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_id"], name: "index_registrations_on_event_id"
    t.index ["user_id"], name: "index_registrations_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "user_name"
    t.string "gender"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email"
    t.string "user_id"
    t.string "user_image"
    t.string "comment"
    t.integer "prefecture_code"
    t.integer "city_code"
    t.date "birthday"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["user_id"], name: "index_users_on_user_id", unique: true
  end

  add_foreign_key "events", "groups"
  add_foreign_key "participations", "groups"
  add_foreign_key "participations", "users"
  add_foreign_key "places", "events"
  add_foreign_key "registrations", "events"
  add_foreign_key "registrations", "users"
end
