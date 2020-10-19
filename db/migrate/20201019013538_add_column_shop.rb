class AddColumnShop < ActiveRecord::Migration[5.2]
  def change
  	add_column :shops, :extension, :integer
  end
end
