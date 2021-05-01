class CreateRoles < ActiveRecord::Migration[6.1]
  def change
    create_table :roles, comment: '権限管理テーブル' do |t|
      t.string :name, null: false, comment: '名称'
    end
    add_index :roles, :name, unique: true
  end
end
