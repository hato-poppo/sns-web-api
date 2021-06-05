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

ActiveRecord::Schema.define(version: 2021_04_30_233635) do

  create_table "posts", charset: "utf8mb4", comment: "投稿テーブル", force: :cascade do |t|
    t.bigint "parent_id", comment: "親投稿ID"
    t.bigint "user_id", null: false, comment: "投稿者"
    t.string "title", null: false, comment: "投稿タイトル"
    t.string "text", null: false, comment: "投稿内容"
    t.boolean "is_deleted", default: false, null: false, comment: "削除フラグ"
    t.datetime "created_at", default: -> { "current_timestamp()" }, comment: "登録日"
    t.datetime "updated_at", default: -> { "current_timestamp()" }, comment: "更新日"
    t.index ["parent_id"], name: "index_posts_on_parent_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "roles", charset: "utf8mb4", comment: "権限管理テーブル", force: :cascade do |t|
    t.string "name", null: false, comment: "名称"
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "users", charset: "utf8mb4", comment: "ユーザー管理テーブル", force: :cascade do |t|
    t.string "uid", null: false, comment: "ユーザーID"
    t.string "name", null: false, comment: "ユーザー名"
    t.string "email", null: false, comment: "Eメールアドレス"
    t.string "password", comment: "パスワード（パスワード認証時に使用）"
    t.bigint "role_id", null: false, comment: "権限ID"
    t.boolean "is_active", default: true, null: false, comment: "有効フラグ"
    t.datetime "created_at", default: -> { "current_timestamp()" }, comment: "登録日"
    t.datetime "updated_at", default: -> { "current_timestamp()" }, comment: "更新日"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

  add_foreign_key "posts", "posts", column: "parent_id"
  add_foreign_key "posts", "users"
  add_foreign_key "users", "roles"
end
