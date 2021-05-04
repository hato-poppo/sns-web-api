class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts, comment: '投稿テーブル' do |t|
      t.references :user, null: false, foreign_key: true, comment: '投稿者'
      t.string :title, null: false, comment: '投稿タイトル'
      t.string :text, null: false, comment: '投稿内容'
      t.boolean :is_deleted, null: false, default: false, comment: '削除フラグ'
      t.datetime :created_at, default: -> { 'NOW()' }, comment: '登録日'
      t.datetime :updated_at, default: -> { 'NOW()' }, comment: '更新日'
    end
    add_reference :posts, :parent, foreign_key: { to_table: :posts }, null: false, after: :id, comment: '親投稿ID'
  end
end
