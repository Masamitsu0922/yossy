class TableGirl < ApplicationRecord
	belongs_to :today_girl, optional: true
	belongs_to :table

	def self.hall_action(params)
		shop = Shop.find(params[:shop_id])
		table_girl = TableGirl.find(params[:id])
		today_girl = table_girl.today_girl
		table = table_girl.table
		#指名に伴う場内バックの計算
		add_hall_back = today_girl.back_wage + shop.hall_back
		today_girl.update!(back_wage:add_hall_back)

		#場内指名料金を会計に加算
		add_hall_price = table.payment + shop.hall_price
		table.update!(payment:add_hall_price)
		return today_girl,table
	end
end
