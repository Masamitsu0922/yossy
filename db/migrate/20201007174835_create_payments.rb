class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
    	t.integer :today_grade_id
    	t.string :item
    	t.string :name
    	t.integer :price
    	t.text :memo
    	t.timestamps
    end
  end
end
