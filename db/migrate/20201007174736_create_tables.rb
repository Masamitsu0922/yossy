class CreateTables < ActiveRecord::Migration[5.2]
  def change
    create_table :tables do |t|
    	t.integer :today_id, null: false
    	t.time :time, null: false
    	t.integer :member, null: false
    	t.integer :price, null: false
    	t.integer :set_time, null: false
    	t.string :name
    	t.text :memo
    	t.string :set_count, null: false
    	t.integer :payment_method, default: 0
    	t.integer :payment
    	t.integer :card_payment
    	t.boolean :tax, default: false
    	t.timestamps
    end
  end
end
