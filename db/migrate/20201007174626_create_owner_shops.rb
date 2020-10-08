class CreateOwnerShops < ActiveRecord::Migration[5.2]
  def change
    create_table :owner_shops do |t|
    	t.integer :owner_id, null: false
    	t.integer :shop_id, null: false
    	t.boolean :is_authority, null: false
	    t.timestamps
    end
  end
end
