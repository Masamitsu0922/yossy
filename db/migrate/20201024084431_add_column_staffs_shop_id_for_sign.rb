class AddColumnStaffsShopIdForSign < ActiveRecord::Migration[5.2]
  def change
  	add_column :staffs, :shop_id_for_sign,:string
  end
end
