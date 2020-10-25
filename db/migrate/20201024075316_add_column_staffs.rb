class AddColumnStaffs < ActiveRecord::Migration[5.2]
  def change
  	change_column :staffs, :email, :string,null: true
  	change_column :staffs, :encrypted_password, :string, default: "", null: true
  end
end
