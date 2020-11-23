class TodayGirl < ApplicationRecord
	belongs_to :girl, optional: true
	belongs_to :today
	has_one :table_girl
	has_many :nameds

	enum girl_status:{
		registry:0,
		dispatch:1,
		experience:2
	}

	enum attendance_status:{
		not_yet:0,
		attend:1,
		end:2
	}
	def self.attendance_update(shop,params,today_girl,today_grade)
		if today_girl.attendance_status_i18n == "未出勤"
			start_time = Time.local(params[:today_girl][:"start_time(1i)"],params[:today_girl][:"start_time(2i)"],params[:today_girl][:"start_time(3i)"],params[:today_girl][:"start_time(4i)"],params[:today_girl][:"start_time(5i)"])
			today_girl.update(start_time:start_time,attendance_status: "attend")
		elsif today_girl.attendance_status_i18n == "出勤済み"
			end_time = Time.local(params[:today_girl][:"end_time(1i)"],params[:today_girl][:"end_time(2i)"],params[:today_girl][:"end_time(3i)"],params[:today_girl][:"end_time(4i)"],params[:today_girl][:"end_time(5i)"])
			today_girl.update(end_time:end_time,attendance_status: "end")
		end


		if today_girl.attendance_status_i18n == "退勤済み"
			#退勤時に給料計算及び支払い項目の追加
			if today_girl.start_time.hour >  today_girl.end_time.hour
				#出勤中に日付が変わっていた場合の処理
				start_time_for_calculate = (24 - today_girl.start_time.hour) + (today_girl.start_time.min / 60)
				end_time_for_calculate = today_girl.end_time.hour + (today_girl.end_time.min / 60)
				total_time = start_time_for_calculate + end_time_for_calculate
			else
				total_time = (today_girl.end_time - today_girl.start_time) / 3600
			end

			time_wage = total_time.to_i * today_girl.slide_wage

			total_back = today_girl.back_wage

			total_wage = time_wage + total_back

			girl_grade = GirlGrade.new(girl_id:today_girl.girl_id,mounth_grade_id:shop.today.mounth_grade_id,date:shop.today.date,sale:today_girl.sale,payment:total_wage)
			girl_grade.save

			if today_girl.is_all_today == true
				#全日の場合
				Payment.create(today_grade_id:today_grade.id,item:"人件費",name:today_girl.name,price:total_wage)
				girl_grade.update(payment:0)
			elsif today_girl.today_payment != 0 && today_girl.today_payment != nil
				#日払いが発生する場合
				Payment.create(today_grade_id:today_grade.id,item:"人件費（日払い）",name:today_girl.name,price:today_girl.today_payment)
				payment_without = girl_grade.payment - today_girl.today_payment
				#キャスト成績の給料の値から日払い金額を引く
				girl_grade.update(payment:payment_without)
			end
		end
	end

end
