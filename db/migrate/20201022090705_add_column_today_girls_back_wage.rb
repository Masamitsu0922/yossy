class AddColumnTodayGirlsBackWage < ActiveRecord::Migration[5.2]
  def change
  	add_column :today_girls, :back_wage,:integer,default:0
  end
end
