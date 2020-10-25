class TodayGirlsController < ApplicationController
	def edit
		@shop = Shop.find(params[:shop_id])
		@today_girl = TodayGirl.find(params[:id])
	end

	def update
		shop = Shop.find(params[:shop_id])
		@today_girl = TodayGirl.find(params[:id])
		@today_girl.update(today_girl_params)

		if @today_girl.attendance_status == 2
			#退勤時に給料計算及び支払い項目の追加
			total_time = (@today_girl.start_time -  @today_girl.end_time) / 3600
			time_wage = total_time * @today_girl.slide_wage
			total_back = @today_girl.back_wage
			total_wage = time_wage + total_wage
			GirlGrade.create(girl_id:@today_girl.girl_id,mounth_grade_id:shop.today.mounth_grade_id,date:shop.today.date,sale:@today_girl.sale,payment:total_wage)
			Payment.create(today_grade_id:shop.today.mounth_grade.find_by(date:shop.today.date).id,item:"人件費",name:@today_girl.name,price:@total_wage)
		end
		redirect_to shop_todays_index_path(params[:shop_id])
	end

	private
	def today_girl_params
		params.require(:today_girl).permit(:start_time,:end_time,:attendance_status)
	end
end
