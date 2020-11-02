class TodaysController < ApplicationController
	before_action :check_user_basic
	#オーナー、スタッフどちらかログインしているか確認
	before_action :check_staff_leader,except: :index
	#スタッフリーダーであるか確認
	before_action :check_master_owner,except: :index
	#マスターオーナーであるか確認
	before_action :set_shop_status
	before_action :check_detial
	#店舗詳細情報が未入力の場合、詳細情報入力画面に飛ばす

	def new
		@today = @shop.today
		@girls = @shop.girls
		@today.today_girls.build
	end

	def create
		@today = @shop.today

		ActiveRecord::Base.transaction do
			if @today.date != params[:today][:date]
				@today.update!(date:params[:today][:date].to_i)

				if @shop.mounth_grades.find_by(mounth:Date.today.month) == nil
					month = MounthGrade.new(shop_id:@shop.id,mounth:Date.today.month)
					month.save
					@today.update!(mounth_grade_id:month.id)
					TodayGrade.create!(mounth_grade_id:month.id,date:@today.date,sale:0,card_sale:0)
				else
					TodayGrade.create!(mounth_grade_id:@today.mounth_grade_id,date:@today.date,sale:0,card_sale:0)
				end
			end

			params[:today][:today_girls_attributes].values.each do |param|
				#集金キャストレコードの作成
				if param[:"girl_id"] != nil
					if param[:"girl_id"].to_i != 0
						#チェックが入っていない項目を処理から弾く（在籍キャストの処理）
					  	start_time = Time.local(param[:"start_time(1i)"],param[:"start_time(2i)"],param[:"start_time(3i)"],param[:"start_time(4i)"],param[:"start_time(5i)"])
				      	end_time = Time.local(param[:"end_time(1i)"],param[:"end_time(2i)"],param[:"end_time(3i)"],param[:"end_time(4i)"],param[:"end_time(5i)"])
				      	name = Girl.find_by(id: param[:"girl_id"].to_i).name
						today_girl = TodayGirl.new(sale:0,today_id: @shop.today.id, girl_id: param[:"girl_id"].to_i,name: name, start_time: start_time,end_time: end_time,slide_wage: Girl.find_by(id:(param[:"girl_id"]).to_i).wage, destination: param[:"destination"], girl_status: 0, today_payment: param[:"today_payment"])
						today_girl.save!
					end
				elsif param[:"girl_status"].to_i == 1 || param[:"girl_status"].to_i == 2
					#派遣ステータスが入力されている項目を処理する
					start_time = Time.local(param[:"start_time(1i)"],param[:"start_time(2i)"],param[:"start_time(3i)"],param[:"start_time(4i)"],param[:"start_time(5i)"])
				    end_time = Time.local(param[:"end_time(1i)"],param[:"end_time(2i)"],param[:"end_time(3i)"],param[:"end_time(4i)"],param[:"end_time(5i)"])
				    today_girl = TodayGirl.new(sale:0,name:param[:"name"],today_id: @shop.today.id, start_time: start_time,end_time: end_time,slide_wage: param[:"slide_wage"], destination: param[:"destination"], girl_status: param[:"girl_status"].to_i, today_payment: param[:"today_payment"],is_all_today: param[:"is_all_today"])
				    today_girl.save!
				end
			end
		end
		redirect_to shop_top_path(@shop.id)
	end

	def index
		@today = @shop.today
		@today_girls = @today.today_girls.sort{ |a,b| a[:end_time] <=> b[:end_time]}
	end

	def confirm
	end

	def destroy

		if Date.today.day != @shop.today.date
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
		elsif Date.today.day == @shop.today.date
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
		TodayGrade.create(mounth_grade_id:mounth.id,date:day,sale:0,card_sale:0)

		redirect_to shop_top_path(@shop.id)
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
			unless current_staff.is_authority ==true
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
		end
		@mounth_grade = MounthGrade.find_by(id:@shop.today.mounth_grade_id)
		@today_grade = @mounth_grade.today_grades.find_by(date:@shop.today.date)
	end

	def check_detial
        if @shop.set_price == nil ||  @shop.name_price == nil || @shop.hall_price == nil || @shop.accompany == nil || @shop.drink == nil ||  @shop.shot == nil ||  @shop.tax == nil ||  @shop.card_tax == nil ||  @shop.accompany_system == nil ||  @shop.table == nil ||  @shop.vip == nil ||  @shop.vip_price == nil ||  @shop.drink_back == nil ||  @shop.shot_back == nil ||  @shop.bottle_back == nil ||  @shop.name_back == nil ||  @shop.hall_back == nil ||  @shop.slide_line == nil ||  @shop.slide_wage == nil ||  @shop.deadline == nil ||  @shop.payment_date == nil ||  @shop.extension == nil ||  @shop.extension_price == nil ||  @shop.accompany_back == nil
            redirect_to shop_detial_path(@shop.id)
            flash[:alert] = "未入力項目があります※半角入力（使用しない値には0を入力してください)"
        end
    end

end
