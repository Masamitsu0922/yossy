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

ActiveRecord::Schema.define(version: 2020_10_31_113849) do

  create_table "catches", force: :cascade do |t|
    t.integer "shop_id"
    t.string "name"
    t.float "back"
    t.integer "back_date"
    t.integer "agreement"
    t.integer "agreement_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.integer "shop_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "girl_grades", force: :cascade do |t|
    t.integer "girl_id"
    t.integer "mounth_grade_id"
    t.integer "date"
    t.integer "sale"
    t.integer "payment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "girls", force: :cascade do |t|
    t.integer "shop_id"
    t.integer "wage"
    t.string "destination"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mounth_grades", force: :cascade do |t|
    t.integer "shop_id"
    t.integer "mounth"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "nameds", force: :cascade do |t|
    t.integer "table_id"
    t.integer "today_girl_id"
    t.integer "named_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "table_id", null: false
    t.integer "quantity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "owner_shops", force: :cascade do |t|
    t.integer "owner_id", null: false
    t.integer "shop_id", null: false
    t.boolean "is_authority", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "owners", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_owners_on_email", unique: true
    t.index ["reset_password_token"], name: "index_owners_on_reset_password_token", unique: true
  end

  create_table "payments", force: :cascade do |t|
    t.integer "today_grade_id"
    t.string "item"
    t.string "name"
    t.integer "price"
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.integer "category_id"
    t.string "name"
    t.integer "back_wage"
    t.integer "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shops", force: :cascade do |t|
    t.string "name", null: false
    t.string "postal_code", null: false
    t.string "address", null: false
    t.string "email", null: false
    t.string "shop_id", null: false
    t.string "password", null: false
    t.integer "girl_wage"
    t.integer "staff_wage"
    t.integer "set_price"
    t.integer "name_price"
    t.integer "hall_price"
    t.integer "accompany"
    t.integer "drink"
    t.integer "shot"
    t.float "tax"
    t.float "card_tax"
    t.integer "accompany_system"
    t.integer "table"
    t.integer "vip"
    t.integer "vip_price"
    t.integer "drink_back"
    t.integer "shot_back"
    t.integer "bottle_back"
    t.integer "name_back"
    t.integer "hall_back"
    t.integer "slide_line"
    t.integer "slide_wage"
    t.integer "deadline"
    t.integer "payment_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "extension"
    t.integer "extension_price"
  end

  create_table "staffs", force: :cascade do |t|
    t.string "email", default: ""
    t.string "encrypted_password", default: ""
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.integer "wage", null: false
    t.boolean "is_authority", default: false, null: false
    t.integer "shop_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "shop_id_for_sign"
    t.string "password"
  end

  create_table "table_girls", force: :cascade do |t|
    t.integer "today_girl_id"
    t.integer "table_id"
    t.integer "name_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tables", force: :cascade do |t|
    t.integer "today_id", null: false
    t.time "time"
    t.integer "member", null: false
    t.integer "price", null: false
    t.integer "set_time", null: false
    t.string "name"
    t.text "memo"
    t.integer "set_count", null: false
    t.integer "payment_method", default: 0
    t.float "payment", default: 0.0
    t.float "card_payment", default: 0.0
    t.boolean "tax", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "number"
  end

  create_table "today_girls", force: :cascade do |t|
    t.integer "today_id"
    t.integer "girl_id"
    t.integer "slide_wage"
    t.integer "sale"
    t.string "destination"
    t.integer "girl_status"
    t.integer "today_payment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.time "start_time"
    t.time "end_time"
    t.string "name"
    t.boolean "is_all_today"
    t.integer "attendance_status", default: 0
    t.integer "back_wage", default: 0
  end

  create_table "today_grades", force: :cascade do |t|
    t.integer "mounth_grade_id"
    t.integer "date"
    t.integer "sale"
    t.integer "card_sale"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "todays", force: :cascade do |t|
    t.integer "shop_id"
    t.integer "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mounth_grade_id"
  end

end
