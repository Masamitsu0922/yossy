class ProductsController < ApplicationController

	before_action :check_user_basic
	#オーナー、スタッフどちらかログインしているか確認
	before_action :check_master_owner
	#マスターオーナーであるか確認
	before_action :set_shop_status

	before_action :check_detial
	#店舗詳細情報が未入力の場合、詳細情報入力画面に飛ばす

	def new
		@product = Product.new
		@categories = Category.where(shop_id:@shop.id)
	end

	def create
		@product = Product.new(product_params)
		if @product.category_id == 1
			@product.back_wage = @shop.drink_back

		elsif @product.category_id == 2
			@product.back_wage = @shop.shot_back

		elsif @product.category_id == 3
			@product.back_wage = @shop.bottle_back
		else
			@product.back_wage =  0
		end

		@product.save
		redirect_to new_shop_product_path(@shop.id)

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

	def product_params
		params.require(:product).permit(:shop_id,:category_id,:name,:price,:back_wage)
	end
end
