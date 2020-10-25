class TableGirlsController < ApplicationController
	def update
		shop = Shop.find(params[:shop_id])
		table_girl = TableGirl.find(params[:id])
		table_girl.update(name_status:2)
		today_girl = table_girl.today_girl
		hall_back =today_girl.back_wage + shop.hall_back
		today_girl.update(back_wage:hall_back)
		redirect_to shop_top_path(params[:shop_id])
	end
end
