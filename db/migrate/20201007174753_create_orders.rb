class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
    	t.integer :product_id, null: false
    	t.integer :table_id, null: false
    	t.integer :quantity, null: false
      t.timestamps
    end
  end
end
