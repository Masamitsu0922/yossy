class CreateGirlGrades < ActiveRecord::Migration[5.2]
  def change
    create_table :girl_grades do |t|
    	t.integer :girl_id
    	t.integer :mounth_grade_id
    	t.integer :date
    	t.integer :sale
    	t.integer :payment
    	t.timestamps
    end
  end
end
