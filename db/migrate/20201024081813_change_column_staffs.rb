class ChangeColumnStaffs < ActiveRecord::Migration[5.2]
  def change
    remove_index :staffs, column: :email,unique: true
    remove_index :staffs,column: :reset_password_token,unique: true
  end
end
