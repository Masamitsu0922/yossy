class TodayGradesController < ApplicationController

	before_action :check_user_basic
	#オーナー、スタッフどちらかログインしているか確認
	before_action :check_master_owner
	#マスターオーナーであるか確認
	before_action :check_detial
	#店舗詳細情報が未入力の場合、詳細情報入力画面に飛ばす

	def show
		@shop = Shop.find(params[:shop_id])
		@mounth_grade = MounthGrade.find(params[:mounth_grade_id])
		@today_grade = @mounth_grade.today_grades.find(params[:id])
		@payment = 0

		@today_grade.payments.each do |payment|
			@payment += payment.price
		end
	end

	private
	def check_user_basic
		if owner_signed_in?
		else
			redirect_to root_path
		end
	end

	def check_master_owner
		if owner_signed_in?
			unless current_owner.owner_shops.find_by(shop_id:params[:shop_id]).is_authority == true
				redirect_to shops_path(current_owner.id)
				flash[:alert] = "権限がありません"
			end
		end
	end

	def check_detial
		@shop = Shop.find(params[:shop_id])
        if @shop.set_price == nil ||  @shop.name_price == nil || @shop.hall_price == nil || @shop.accompany == nil || @shop.drink == nil ||  @shop.shot == nil ||  @shop.tax == nil ||  @shop.card_tax == nil ||  @shop.accompany_system == nil ||  @shop.table == nil ||  @shop.vip == nil ||  @shop.vip_price == nil ||  @shop.drink_back == nil ||  @shop.shot_back == nil ||  @shop.bottle_back == nil ||  @shop.name_back == nil ||  @shop.hall_back == nil ||  @shop.slide_line == nil ||  @shop.slide_wage == nil ||  @shop.deadline == nil ||  @shop.payment_date == nil || @shop.extension_price == nil ||  @shop.accompany_back == nil
            redirect_to shop_detial_path(@shop.id)
            flash[:alert] = "未入力項目があります※半角入力（使用しない値には0を入力してください)"
        end
    end

end
