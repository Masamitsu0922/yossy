class GirlsController < ApplicationController

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
	def girl_params
		params.require(:girl).permit(:shop_id,:name,:wage,:destination)
	end
end
