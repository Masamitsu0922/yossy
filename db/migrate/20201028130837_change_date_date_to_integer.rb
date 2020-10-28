class ChangeDateDateToInteger < ActiveRecord::Migration[5.2]
  def change
  	change_column :todays, :date, :integer
  end
end
