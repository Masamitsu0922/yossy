class ChangeDataCardPaymentToTable < ActiveRecord::Migration[5.2]
  def change
  	change_column :tables, :card_payment, :float
  	change_column :tables, :payment, :float
  end
end
