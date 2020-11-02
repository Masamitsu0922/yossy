class TodayGirlsController < ApplicationController
	before_action :check_user_basic
	#オーナー、スタッフどちらかログインしているか確認
	before_action :check_staff_leader
	#スタッフリーダーであるか確認
	before_action :check_master_owner
	#マスターオーナーであるか確認
	before_action :set_shop_status

	before_action :check_detial
	#店舗詳細情報が未入力の場合、詳細情報入力画面に飛ばす

	def edit
		@today_girl = TodayGirl.find(params[:id])
	end

	def update
		shop = Shop.find(params[:shop_id])
		@today_girl = TodayGirl.find(params[:id])

		ActiveRecord::Base.transaction do

			if @today_girl.attendance_status == 0
				start_time = Time.local(params[:today_girl][:"start_time(1i)"],params[:today_girl][:"start_time(2i)"],params[:today_girl][:"start_time(3i)"],params[:today_girl][:"start_time(4i)"],params[:today_girl][:"start_time(5i)"])
				@today_girl.update(start_time:start_time,attendance_status: 1)
			elsif @today_girl.attendance_status == 1
				end_time = Time.local(params[:today_girl][:"end_time(1i)"],params[:today_girl][:"end_time(2i)"],params[:today_girl][:"end_time(3i)"],params[:today_girl][:"end_time(4i)"],params[:today_girl][:"end_time(5i)"])
				@today_girl.update(end_time:end_time,attendance_status: 2)
			end


			if @today_girl.attendance_status == 2
				#退勤時に給料計算及び支払い項目の追加
				if @today_girl.start_time.hour >  @today_girl.end_time.hour
					#出勤中に日付が変わっていた場合の処理
					start_time_for_calculate = (24 - @today_girl.start_time.hour) + (@today_girl.start_time.min / 60)
					end_time_for_calculate = @today_girl.end_time.hour + (@today_girl.end_time.min / 60)
					total_time = start_time_for_calculate + end_time_for_calculate
				else
					total_time = (@today_girl.end_time - @today_girl.start_time) / 3600
				end

				time_wage = total_time.to_i * @today_girl.slide_wage

				total_back = @today_girl.back_wage

				total_wage = time_wage + total_back

				girl_grade = GirlGrade.new(girl_id:@today_girl.girl_id,mounth_grade_id:shop.today.mounth_grade_id,date:shop.today.date,sale:@today_girl.sale,payment:total_wage)
				girl_grade.save

				if @today_girl.today_payment != 0 && @today_girl.today_payment != nil
					#日払いがある場合
					if @today_girl.is_all_today == true
						Payment.create(today_grade_id:@today_grade.id,item:"人件費",name:@today_girl.name,price:total_wage)
						girl_grade.update(payment:0)
					else
						Payment.create(today_grade_id:@today_grade.id,item:"人件費（日払い）",name:@today_girl.name,price:@today_girl.today_payment)
						payment_without = girl_grade.payment - @today_girl.today_payment
						#キャスト成績の給料の値から日払い金額を引く
						girl_grade.update(payment:payment_without)
					end
				end

			end
		end
		redirect_to shop_todays_index_path(params[:shop_id])

		rescue
			redirect_to shop_todays_index_path(@shop.id)
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
			@today_grade = @mounth_grade.today_grades.find_by(date:@shop.today.date)
		end
	end

	def check_detial
        if @shop.set_price == nil ||  @shop.name_price == nil || @shop.hall_price == nil || @shop.accompany == nil || @shop.drink == nil ||  @shop.shot == nil ||  @shop.tax == nil ||  @shop.card_tax == nil ||  @shop.accompany_system == nil ||  @shop.table == nil ||  @shop.vip == nil ||  @shop.vip_price == nil ||  @shop.drink_back == nil ||  @shop.shot_back == nil ||  @shop.bottle_back == nil ||  @shop.name_back == nil ||  @shop.hall_back == nil ||  @shop.slide_line == nil ||  @shop.slide_wage == nil ||  @shop.deadline == nil ||  @shop.payment_date == nil || @shop.extension_price == nil ||  @shop.accompany_back == nil
            redirect_to shop_detial_path(@shop.id)
            flash[:alert] = "未入力項目があります※半角入力（使用しない値には0を入力してください)"
        end
    end

	def today_girl_params
		params.require(:today_girl).permit(:start_time,:end_time,:attendance_status)
	end
end
