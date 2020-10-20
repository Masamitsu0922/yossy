class TodaysController < ApplicationController
	def new
		shop = Shop.find(params[:shop_id])
		@today = shop.today
		@girls = shop.girls
		@today.today_girls.build
	end

	def create
		shop = Shop.find(params[:shop_id])
		@today = shop.today
		@today.update(date:params[:today][:date].to_i)

		params[:today][:today_girls_attributes].values.each do |param|
			if param[:"girl_id"].to_i != 0
			  	start_time = Time.local(param[:"start_time(1i)"],param[:"start_time(2i)"],param[:"start_time(3i)"],param[:"start_time(4i)"],param[:"start_time(5i)"],)
		      	end_time = Time.local(param[:"end_time(1i)"],param[:"end_time(2i)"],param[:"end_time(3i)"],param[:"end_time(4i)"],param[:"end_time(5i)"],)
				today_girls = TodayGirl.new(today_id: shop.today.id, girl_id: param[:"girl_id"].to_i, start_time: start_time,end_time: end_time, destination: param[:"destination"])
				today_girls.save
			end
		end
		redirect_to shop_top_path(shop.id)
	end

	def index
		shop = Shop.find(params[:shop_id])
		today = shop.today
		@today_girls = today.today_girls
	end

	def confirm
		@shop = Shop.find(params[:shop_id])
	end

	def destroy
		@shop = Shop.find(params[:shop_id])

		if Date.today.day != @shop.today.day
			#営業中に日付が変わった場合
			day = Date.today.day

				if @shop.mounth_grades.find_by(mounth:Date.today.month) == []
					#アクション中の日付を参照し対応する月度成績テーブルがなかった場合
					mounth = Mounth.new(shop_id:@shop.id,mounth:Date.today.month)
					mounth.save
					@shop.mounth_grades.find_by(mounth:Date.today.month - 4).destroy
				else
					mounth = @shop.mounth_grades.find_by(mounth:Date.today.month)
				end
			#month = Date.today.month
		elsif Date.today.day == @shop.today.day
			#営業中に日付が変わらなかった場合
				if @shop.mounth_grades.find_by(mounth:Date.tomorrow.month) == []
					#アクション中の翌日の日付を参照し対応する月度成績テーブルがなかった場合
					mounth = Mounth.new(shop_id:@shop.id,mounth:Date.today.month)
					mounth.save
					day = 1
					@shop.mounth_grades.find_by(mounth:Date.tomorrow.month - 4).destroy
				else
					day = Date.today.day + 1
					mounth = @shop.mounth_grades.find_by(mounth:Date.today.month)
				end
			#month = Date.today.month
		end


		@shop.today.destroy


		Today.create(shop_id:@shop.id, date:day,mounth_grade_id:mounth.id)
		TodayGrade.create(mounth_grade_id:mounth.id)

		redirect_to shop_top_path(@shop.id)
	end

end
