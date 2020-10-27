class GirlsController < ApplicationController
	before_action :set_shop_status

	def index
		@girl = Girl.new
		shop = Shop.find(params[:shop_id])
		@girls = shop.girls
	end

	def create
		@girl = Girl.new(girl_params)
		@girl.shop_id=params[:shop_id]
		@girl.save
		redirect_to shop_girls_path(params[:shop_id])
	end

	private

	def set_shop_status
		@shop=Shop.find(params[:shop_id])
		if @shop.today != nil
			if @shop.today.today_girls != nil
				@today_girls = @shop.today.today_girls.where(attendance_status: 1)
			end
			@mounth_grade = MounthGrade.find_by(id:@shop.today.mounth_grade_id)
			@today_grade = TodayGrade.find_by(date:@shop.today.date)
		end
	end
	def girl_params
		params.require(:girl).permit(:shop_id,:name,:wage,:destination)
	end
end
