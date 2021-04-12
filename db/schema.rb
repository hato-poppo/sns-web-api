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

ActiveRecord::Schema.define(version: 2021_04_11_094704) do

  create_table "users", charset: "utf8mb4", comment: "ユーザー管理テーブル", force: :cascade do |t|
    t.string "login_id", null: false, comment: "ログインID"
    t.string "name", null: false, comment: "ユーザー名"
    t.string "email", null: false, comment: "Eメールアドレス"
    t.string "password", comment: "パスワード（パスワード認証時に使用）"
    t.boolean "is_active", default: true, null: false, comment: "有効フラグ"
    t.datetime "created_at", default: -> { "current_timestamp()" }, comment: "登録日"
    t.datetime "updated_at", default: -> { "current_timestamp()" }, comment: "更新日"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["login_id"], name: "index_users_on_login_id", unique: true
  end

end
