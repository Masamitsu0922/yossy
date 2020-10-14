class TodaysController < ApplicationController
	def new
		@today = Today.new
		shop = Shop.find(params[:shop_id])
		@girls = shop.girls
		@today.today_girls.build
	end

	def create
		shop = Shop.find(params[:shop_id])
		@today = Today.new(today_params.merge(shop_id: shop.id))
		@today.save
		if @today.save
		    params[:today][:today_girls_attributes].each do |v|
				today_girls = TodayGirl.new(today_id: @today.id, girl_id: v[1][:girl_id], time: v[1][:time], destination: v[1][:destination])
				today_girls.save
			end
		end
		redirect_to shops_path
	end

	def index
		shop = Shop.find(params[:shop_id])
		today = shop.today
		@today_girls = today.today_girls
	end

	private
	def today_params
		params.require(:today).permit(:date)
	end
end
