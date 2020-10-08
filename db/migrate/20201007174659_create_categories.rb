class CreateCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :categories do |t|
    	t.integer :shop_id,null: false
    	t.string :name,null: false
    	t.timestamps
    end
  end
end
