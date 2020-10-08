class CreateTodayGirls < ActiveRecord::Migration[5.2]
  def change
    create_table :today_girls do |t|
    	t.integer :today_id
    	t.integer :girl_id
    	t.float :time
    	t.integer :slide_wage
    	t.integer :sale
    	t.string :destination
    	t.integer :girl_status
    	t.integer :today_payment
      t.timestamps
    end
  end
end
