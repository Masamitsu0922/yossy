class CreateTableGirls < ActiveRecord::Migration[5.2]
  def change
    create_table :table_girls do |t|
    	t.integer :today_girl_id
    	t.integer :table_id
    	t.integer :name_status
    	t.timestamps
    end
  end
end
