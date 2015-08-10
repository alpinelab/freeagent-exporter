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

ActiveRecord::Schema.define(version: 20150810211936) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "archive_transitions", force: true do |t|
    t.string   "to_state",                   null: false
    t.text     "metadata",    default: "{}"
    t.integer  "sort_key",                   null: false
    t.integer  "archive_id",                 null: false
    t.boolean  "most_recent",                null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "archive_transitions", ["archive_id", "most_recent"], name: "index_archive_transitions_parent_most_recent", unique: true, where: "most_recent", using: :btree
  add_index "archive_transitions", ["archive_id", "sort_key"], name: "index_archive_transitions_parent_sort", unique: true, using: :btree

  create_table "archives", force: true do |t|
    t.text     "s3_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bank_account_id"
    t.integer  "transactions_left_to_explain"
    t.integer  "month"
    t.integer  "year"
  end

  add_index "archives", ["bank_account_id"], name: "index_archives_on_bank_account_id", using: :btree

  create_table "bank_accounts", force: true do |t|
    t.string   "number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "freeagent_id"
    t.string   "name"
  end

  create_table "bank_accounts_users", id: false, force: true do |t|
    t.integer "bank_account_id"
    t.integer "user_id"
  end

  add_index "bank_accounts_users", ["bank_account_id"], name: "index_bank_accounts_users_on_bank_account_id", using: :btree
  add_index "bank_accounts_users", ["user_id"], name: "index_bank_accounts_users_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "uid"
    t.string   "access_token"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
