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

ActiveRecord::Schema[8.1].define(version: 2025_10_28_095546) do
  create_table "magic_links", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "ip_address"
    t.string "purpose", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.datetime "used_at"
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["expires_at"], name: "index_magic_links_on_expires_at"
    t.index ["token"], name: "index_magic_links_on_token", unique: true
    t.index ["user_id", "purpose", "expires_at"], name: "index_magic_links_on_user_id_and_purpose_and_expires_at"
    t.index ["user_id"], name: "index_magic_links_on_user_id"
  end

  create_table "otp_codes", force: :cascade do |t|
    t.integer "attempts", default: 0, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "ip_address"
    t.integer "max_attempts", default: 3, null: false
    t.string "purpose", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.datetime "verified_at"
    t.index ["expires_at"], name: "index_otp_codes_on_expires_at"
    t.index ["user_id", "code", "purpose"], name: "index_otp_codes_on_user_id_and_code_and_purpose"
    t.index ["user_id", "purpose", "expires_at"], name: "index_otp_codes_on_user_id_and_purpose_and_expires_at"
    t.index ["user_id"], name: "index_otp_codes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "email", null: false
    t.boolean "email_confirmed", default: false, null: false
    t.datetime "email_confirmed_at"
    t.datetime "last_sign_in_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "magic_links", "users"
  add_foreign_key "otp_codes", "users"
end
