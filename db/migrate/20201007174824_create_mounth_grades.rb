class CreateMounthGrades < ActiveRecord::Migration[5.2]
  def change
    create_table :mounth_grades do |t|
    	t.integer :shop_id
    	t.integer :mounth
    	t.timestamps
    end
  end
end
