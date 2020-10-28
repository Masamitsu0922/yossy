class TodayGirlsController < ApplicationController
	before_action :check_user_basic
	#オーナー、スタッフどちらかログインしているか確認
	before_action :check_staff_leader
	#スタッフリーダーであるか確認
	before_action :check_master_owner
	#マスターオーナーであるか確認
	before_action :set_shop_status,except: :index

	def edit
		@today_girl = TodayGirl.find(params[:id])
	end

	def update
		shop = Shop.find(params[:shop_id])
		@today_girl = TodayGirl.find(params[:id])

		if @today_girl.attendance_status == 0
			start_time = Time.local(params[:today_girl][:"start_time(1i)"],params[:today_girl][:"start_time(2i)"],params[:today_girl][:"start_time(3i)"],params[:today_girl][:"start_time(4i)"],params[:today_girl][:"start_time(5i)"])
			@today_girl.update(start_time:start_time,attendance_status: 1)
		elsif @today_girl.attendance_status == 1
			end_time = Time.local(params[:today_girl][:"end_time(1i)"],params[:today_girl][:"end_time(2i)"],params[:today_girl][:"end_time(3i)"],params[:today_girl][:"end_time(4i)"],params[:today_girl][:"end_time(5i)"])
			@today_girl.update(end_time:end_time,attendance_status: 2)
		elsif @today_girl.attendance_status == 2
		end


		if @today_girl.attendance_status == 2
			#退勤時に給料計算及び支払い項目の追加
			if @today_girl.start_time >  @today_girl.end_time
				#出勤中に日付が変わっていた場合の処理
				start_time_for_calculate = (24 - @today_girl.start_time.hour)+(@today_girl.start_time.min / 60)
				end_time_for_calculate = @today_girl.end_time.hour +(@today_girl.end_time.min / 60)
				total_time = start_time_for_calculate + end_time_for_calculate
			else
				total_time = (@today_girl.start_time -  @today_girl.end_time) / 3600
			end

			time_wage = total_time.to_i * @today_girl.slide_wage

			total_back = @today_girl.back_wage

			total_wage = time_wage + total_back


			GirlGrade.create(girl_id:@today_girl.girl_id,mounth_grade_id:shop.today.mounth_grade_id,date:shop.today.date,sale:@today_girl.sale,payment:total_wage)
			Payment.create(today_grade_id:shop.today.mounth_grade.today_grades.find_by(date:shop.today.date).id,item:"人件費",name:@today_girl.name,price:total_wage)
		end
		redirect_to shop_todays_index_path(params[:shop_id])
	end

	private
	def check_user_basic
		if owner_signed_in? || staff_signed_in?
		else
			redirect_to root_path
		end
	end

	def check_staff_leader
		if staff_signed_in?
			unless current_staff.is_authority == true
				redirect_to shop_top_path(params[:shop_id])
			end
		end

	end

	def check_master_owner
		if owner_signed_in?
			unless current_owner.owner_shops.find_by(shop_id:params[:shop_id]).is_authority == true
				redirect_to shops_path(current_owner.id)
			end
		end
	end

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

	def today_girl_params
		params.require(:today_girl).permit(:start_time,:end_time,:attendance_status)
	end
end