class AddColumnTodays < ActiveRecord::Migration[5.2]
  def change
  	add_column :todays, :mounth_grade_id, :integer
  end
end
