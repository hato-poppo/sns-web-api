class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users, comment: 'ユーザー管理テーブル' do |t|
      t.string :login_id, null: false, comment: 'ログインID'
      t.string :name, null: false, comment: 'ユーザー名'
      t.string :email, null: false, comment: 'Eメールアドレス'
      t.string :password, comment: 'パスワード（パスワード認証時に使用）'
      t.boolean :is_active, null: false, default: 1, comment: '有効フラグ'
      t.datetime :created_at, default: -> { 'NOW()' }, comment: '登録日'
      t.datetime :updated_at, default: -> { 'NOW()' }, comment: '更新日'
    end
    add_index :users, :login_id, unique: true
    add_index :users, :email, unique: true
  end
end