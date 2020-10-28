class TodaysController < ApplicationController
	before_action :check_user_basic
	#オーナー、スタッフどちらかログインしているか確認
	before_action :check_staff_leader,except: :index
	#スタッフリーダーであるか確認
	before_action :check_master_owner,except: :index
	#マスターオーナーであるか確認
	before_action :set_shop_status

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
		binding.pry

		params[:today][:today_girls_attributes].values.each do |param|
			if param[:"girl_id"] != nil
				if param[:"girl_id"].to_i != 0
				  	start_time = Time.local(param[:"start_time(1i)"],param[:"start_time(2i)"],param[:"start_time(3i)"],param[:"start_time(4i)"],param[:"start_time(5i)"])
			      	end_time = Time.local(param[:"end_time(1i)"],param[:"end_time(2i)"],param[:"end_time(3i)"],param[:"end_time(4i)"],param[:"end_time(5i)"])
			      	name = Girl.find_by(id: param[:"girl_id"].to_i).name
					today_girl = TodayGirl.new(today_id: shop.today.id, girl_id: param[:"girl_id"].to_i,name: name, start_time: start_time,end_time: end_time,slide_wage: Girl.find_by(id:(param[:"girl_id"]).to_i).wage, destination: param[:"destination"], girl_status: 0, today_payment: param[:"today_payment"])
					today_girl.save
				end
			elsif param[:"girl_status"].to_i == 1 || param[:"girl_status"].to_i == 2
				start_time = Time.local(param[:"start_time(1i)"],param[:"start_time(2i)"],param[:"start_time(3i)"],param[:"start_time(4i)"],param[:"start_time(5i)"])
			    end_time = Time.local(param[:"end_time(1i)"],param[:"end_time(2i)"],param[:"end_time(3i)"],param[:"end_time(4i)"],param[:"end_time(5i)"])
			    today_girl = TodayGirl.new(name:param[:"name"],today_id: shop.today.id, start_time: start_time,end_time: end_time,slide_wage: param[:"slide_wage"], destination: param[:"destination"], girl_status: param[:"girl_status"].to_i, today_payment: param[:"today_payment"],is_all_today: param[:"is_all_today"])
			    today_girl.save
			end
		end
		redirect_to shop_top_path(shop.id)
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
		@today_grade = TodayGrade.find_by(date:@shop.today.date)
	end

end
