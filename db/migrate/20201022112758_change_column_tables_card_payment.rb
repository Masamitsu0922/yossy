class ChangeColumnTablesCardPayment < ActiveRecord::Migration[5.2]
  def change
  	change_column :tables, :payment,:float,default: 0
  	change_column :tables, :card_payment,:float,default: 0
  end
end
