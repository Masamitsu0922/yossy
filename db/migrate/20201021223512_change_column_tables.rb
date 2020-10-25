class ChangeColumnTables < ActiveRecord::Migration[5.2]
  def change
  	change_column :tables, :time,:time,null: true
  end
end
