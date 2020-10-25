class AddcolunTodayGirlsIsAllToday < ActiveRecord::Migration[5.2]
  def change
  	add_column :today_girls, :is_all_today,:boolean
  end
end
