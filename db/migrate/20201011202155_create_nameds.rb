class CreateNameds < ActiveRecord::Migration[5.2]
  def change
    create_table :nameds do |t|
    	t.integer :table_id
    	t.integer :today_girl_id
    	t.integer :named_status
      	t.timestamps
    end
  end
end
