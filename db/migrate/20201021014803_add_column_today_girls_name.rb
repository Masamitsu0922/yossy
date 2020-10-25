class AddColumnTodayGirlsName < ActiveRecord::Migration[5.2]
  def change
  	add_column :today_girls, :name,:string
  end
end
