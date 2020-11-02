class RemoveColimnTableGirls < ActiveRecord::Migration[5.2]
  def change
  	remove_column :table_girls, :name_status, :integer
  	add_column :nameds, :count, :integer , default: 1
  end
end
