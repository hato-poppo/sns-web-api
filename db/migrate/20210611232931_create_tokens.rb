class CreateTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :tokens, id: false, comment: '認証情報テーブル' do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }, comment: '投稿者'
      t.string :hash, null: false, comment: '認証トークン'
      t.datetime :limit, null: false, comment: '期限'
    end
  end
end
