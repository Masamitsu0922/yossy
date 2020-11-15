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

			Today.open_ready(@shop,@today,params)

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

		if @shop.today.today_girls.find_by(attendance_status:1) != nil
			redirect_to shop_todays_index_path(@shop.id)
			flash[:alert] = "退勤処理が終わっていないキャストがいます"

		elsif @shop.today.tables != []
			redirect_to shop_top_path(@shop.id)
			flash[:alert] = "未会計のテーブルがあります"

		else
		ActiveRecord::Base.transaction do
			Today.finish(@shop)
		end

		redirect_to shop_top_path(@shop.id)
		end

		rescue => e
			redirect_to shop_top_path(@shop.id)
			flash[:alert] = "何らかの問題が発生しました"

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
			unless current_staff.is_authority == "スタッフリーダー"
				redirect_to shop_top_path(params[:shop_id])
				flash[:alert] = "権限がありません"
			end
		end

	end

	def check_master_owner
		if owner_signed_in?
			unless current_owner.owner_shops.find_by(shop_id:params[:shop_id]).is_authority_i18n == "マスターオーナー"
				redirect_to shops_path(current_owner.id)
				flash[:alert] = "権限がありません"
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
        if @shop.set_price == nil ||  @shop.name_price == nil || @shop.hall_price == nil || @shop.accompany == nil || @shop.drink == nil ||  @shop.shot == nil ||  @shop.tax == nil ||  @shop.card_tax == nil ||  @shop.accompany_system == nil ||  @shop.table == nil ||  @shop.vip == nil ||  @shop.vip_price == nil ||  @shop.drink_back == nil ||  @shop.shot_back == nil ||  @shop.bottle_back == nil ||  @shop.name_back == nil ||  @shop.hall_back == nil ||  @shop.slide_line == nil ||  @shop.slide_wage == nil ||  @shop.deadline == nil ||  @shop.payment_date == nil || @shop.extension_price == nil ||  @shop.accompany_back == nil
            redirect_to shop_detial_path(@shop.id)
            flash[:alert] = "未入力項目があります※半角入力（使用しない値には0を入力してください)"
        end
    end

end
