class AddColumnStaffPassword < ActiveRecord::Migration[5.2]
  def change

  	add_column :staffs, :password,:string
  end
end
