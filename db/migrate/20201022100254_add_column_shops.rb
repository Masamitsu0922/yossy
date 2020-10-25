class AddColumnShops < ActiveRecord::Migration[5.2]
  def change
  	add_column :shops, :extension_price, :integer
  end
end
