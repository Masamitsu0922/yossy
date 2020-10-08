class CreateTodayGrades < ActiveRecord::Migration[5.2]
  def change
    create_table :today_grades do |t|
    	t.integer :mounth_grade_id
    	t.integer :date
    	t.integer :sale
    	t.integer :card_sale
      t.timestamps
    end
  end
end
