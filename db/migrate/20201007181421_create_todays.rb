class CreateTodays < ActiveRecord::Migration[5.2]
  def change
    create_table :todays do |t|
    	t.integer :shop_id
    	t.date :date
    	t.timestamps
    end
  end
end
