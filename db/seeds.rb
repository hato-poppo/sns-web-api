# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# 権限テーブルレコード作成
Role.create([
  { id: 1, name: 'システム管理者' },
  { id: 2, name: '一般ユーザー' },
])

# ユーザーテーブルレコード作成
User.create([
  { id: 1, uid: 'admin', name: '管理者', email: 'admin@dummy.com', password: 'admin', role_id: 1 }
])
