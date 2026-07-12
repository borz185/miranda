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

ActiveRecord::Schema[8.1].define(version: 2026_07_12_214733) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bonus_products", force: :cascade do |t|
    t.integer "cost_in_points", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.bigint "service_id"
    t.datetime "updated_at", null: false
    t.index ["service_id"], name: "index_bonus_products_on_service_id"
  end

  create_table "promotions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "image_url"
    t.boolean "is_active", default: true
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "services", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "is_active", default: true
    t.decimal "monthly_fee", precision: 10, scale: 2, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tariffs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "is_popular", default: false
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "speed", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "created_at"], name: "index_transactions_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "user_services", force: :cascade do |t|
    t.datetime "activated_at"
    t.datetime "created_at", null: false
    t.boolean "is_bonus", default: false, null: false
    t.boolean "is_enabled", default: false
    t.datetime "last_billing_at"
    t.bigint "service_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["service_id"], name: "index_user_services_on_service_id"
    t.index ["user_id", "service_id"], name: "index_user_services_on_user_id_and_service_id", unique: true
    t.index ["user_id"], name: "index_user_services_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "account_number", null: false
    t.string "address"
    t.decimal "balance", precision: 10, scale: 2, default: "0.0"
    t.integer "bonus_points", default: 0
    t.datetime "created_at", null: false
    t.boolean "discount_active", default: false
    t.string "email", null: false
    t.string "full_name", null: false
    t.string "password_digest", null: false
    t.datetime "tariff_activated_at"
    t.bigint "tariff_id"
    t.datetime "updated_at", null: false
    t.index ["account_number"], name: "index_users_on_account_number", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["tariff_id"], name: "index_users_on_tariff_id"
  end

  add_foreign_key "bonus_products", "services"
  add_foreign_key "transactions", "users"
  add_foreign_key "user_services", "services"
  add_foreign_key "user_services", "users"
  add_foreign_key "users", "tariffs"
end
