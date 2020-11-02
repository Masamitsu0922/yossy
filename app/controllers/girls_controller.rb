class GirlsController < ApplicationController

	before_action :check_user_basic
	#オーナー、スタッフどちらかログインしているか確認
	before_action :check_master_owner
	#マスターオーナーであるか確認
	before_action :set_shop_status

	before_action :check_detial
	#店舗詳細情報が未入力の場合、詳細情報入力画面に飛ばす

	def index
		#マスターオーナーのみ
		@girl = Girl.new
		shop = Shop.find(params[:shop_id])
		@girls = shop.girls
	end

	def create
		#マスターオーナーのみ
		@girl = Girl.new(girl_params)
		@girl.shop_id=params[:shop_id]
		if @girl.save
			redirect_to shop_girls_path(params[:shop_id])
		else
			redirect_to shop_girls_path(params[:shop_id])
			flash[:alert] = "新規作成に失敗しました"
		end
	end

	def show
		@girl = Girl.find(params[:id])
		@girl_grades = @girl.girl_grades.where(mounth_grade_id:@mounth_grade.id)
		@sale = 0
		@payment = 0
		@girl_grades.each do |grade|
			@sale += grade.sale
			@payment += grade.payment
		end
	end

	private

	def check_user_basic
		if owner_signed_in? || staff_signed_in?
		else
			redirect_to root_path
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
        if @shop.set_price == nil ||  @shop.name_price == nil || @shop.hall_price == nil || @shop.accompany == nil || @shop.drink == nil ||  @shop.shot == nil ||  @shop.tax == nil ||  @shop.card_tax == nil ||  @shop.accompany_system == nil ||  @shop.table == nil ||  @shop.vip == nil ||  @shop.vip_price == nil ||  @shop.drink_back == nil ||  @shop.shot_back == nil ||  @shop.bottle_back == nil ||  @shop.name_back == nil ||  @shop.hall_back == nil ||  @shop.slide_line == nil ||  @shop.slide_wage == nil ||  @shop.deadline == nil ||  @shop.payment_date == nil ||  @shop.extension == nil ||  @shop.extension_price == nil ||  @shop.accompany_back == nil
            redirect_to shop_detial_path(@shop.id)
            flash[:alert] = "未入力項目があります※半角入力（使用しない値には0を入力してください)"
        end
    end

	def girl_params
		params.require(:girl).permit(:shop_id,:name,:wage,:destination)
	end
end
