class ProductsController < ApplicationController

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
		redirect_to shop_top_path(@shop.id)

	end

	private

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

	def product_params
		params.require(:product).permit(:shop_id,:category_id,:name,:price,:back_wage)
	end
end
