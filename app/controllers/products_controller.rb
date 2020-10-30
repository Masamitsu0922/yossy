class ProductsController < ApplicationController

	before_action :check_user_basic
	#オーナー、スタッフどちらかログインしているか確認
	before_action :check_master_owner
	#マスターオーナーであるか確認
	before_action :set_shop_status

	def new
		@shop = Shop.find(params[:shop_id])
		@product = Product.new
		@categories = Category.where(shop_id:@shop.id)
	end

	def create
		@shop = Shop.find(params[:shop_id])
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

	def product_params
		params.require(:product).permit(:shop_id,:category_id,:name,:price,:back_wage)
	end
end
