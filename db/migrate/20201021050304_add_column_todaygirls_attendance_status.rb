class AddColumnTodaygirlsAttendanceStatus < ActiveRecord::Migration[5.2]
  def change
  	add_column :today_girls, :attendance_status,:integer,default:0
  end
end
