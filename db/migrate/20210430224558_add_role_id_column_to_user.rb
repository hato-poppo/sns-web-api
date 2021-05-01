class AddRoleIdColumnToUser < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :role, foreign_key: true, null: false, after: :password, comment: '権限ID'
  end
end
