class ShopsController < ApplicationController
	def index
		@owner=current_owner
	end

	def new
		@shop=Shop.new
	end

	def create
		if params[:passward] == params[:passward_verification]
			@shop=Shop.new(shop_params)
			@shop.save
			#オーナーと紐づく中間テーブルの作成
			owner_shop=OwnerShop.new
			owner_shop.owner_id = current_owner.id
			owner_shop.shop_id = @shop.id
			owner_shop.is_authority = true
			owner_shop.save

			redirect_to shop_detial_path(@shop)
		else
			render new
		end
	end

	def detial
		@shop=Shop.find(params[:id])
	end

	def setting
		@shop=Shop.find(params[:id])
		@shop.tax = params[:shop][:tax_percentage].to_f / 100
		@shop.card_tax = params[:shop][:card_tax_percentage].to_f / 100
		@shop.update(shop_params)
		category=Category.new(shop_id: @shop.id,name: "ドリンク")
		category.save

		product=Product.new(category_id: category.id, name: キャストドリンク, back_wage:@shop.drink_back, price: @shop.drink)
		product.save

		redirect_to shops_path
	end

	def add
	end

	def adding
	end

	def top
		@shop=Shop.find(params[:id])
	end

	def roll
		@shop = Shop.find(params[:id])
		@today = @shop.today
		@tables = @shop.today.tables
		@girls = @shop.today.today_girls.map(&:girl)
		@table_girls = @tables.map(&:table_girls)
		@today_girls = TodayGirl.all
		#binding.pry
	end

	def rolling
		#binding.pry
		shop = Shop.find(params[:id])
		today = shop.today
		today.update(today_params)
		#binding.pry
		redirect_to shop_top_path(shop.id)
	end

	private
	def shop_params
		params.require(:shop).permit(:name,:postal_code,:address,:email,:shop_id,:password,:girl_wage,
			:staff_wage,:set_price,:name_price,:hall_price,:accompany,:drink,:shot,:tax,:acconpany_system,
			:table,:vip,:drink_back,:shot_back,:bottle_back,:name_back,:hall_back,:slide_line,:slide_wage,
			:deadline,:payment_date,owner_shops_attributes: [:id, :shop_id, :owner_id ,:is_authority])
	end
	def today_params
		params.require(:today).permit(tables_attributes:[:id,table_girls_attributes:[:id,:today_girl_id]])
	end
end