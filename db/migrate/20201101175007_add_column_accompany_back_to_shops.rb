class AddColumnAccompanyBackToShops < ActiveRecord::Migration[5.2]
  def change
  	add_column :shops,:accompany_back,:integer
  end
end
