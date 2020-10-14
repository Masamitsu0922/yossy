class CreateShops < ActiveRecord::Migration[5.2]
  def change
    create_table :shops do |t|
    	t.string :name,null: false
    	t.string :postal_code,null: false
    	t.string :address,null: false
    	t.string :email,null: false
    	t.string :shop_id,null: false
    	t.string :password,null: false
    	t.integer :girl_wage
    	t.integer :staff_wage
    	t.integer :set_price
    	t.integer :name_price
    	t.integer :hall_price
    	t.integer :accompany
    	t.integer :drink
    	t.integer :shot
    	t.float :tax
        t.float :card_tax
    	t.integer :accompany_system
    	t.integer :table
    	t.integer :vip
        t.integer :vip_price
    	t.integer :drink_back
    	t.integer :shot_back
    	t.integer :bottle_back
    	t.integer :name_back
    	t.integer :hall_back
    	t.integer :slide_line
    	t.integer :slide_wage
    	t.integer :deadline
    	t.integer :payment_date
	    t.timestamps
    end
  end
end
