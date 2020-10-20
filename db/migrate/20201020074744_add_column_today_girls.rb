class AddColumnTodayGirls < ActiveRecord::Migration[5.2]
  def change
  	add_column :today_girls, :start_time,:time
  	add_column :today_girls, :end_time,:time
  	remove_column :today_girls, :time, :integer
  end
end
