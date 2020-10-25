class OrdersController < ApplicationController
	def new
		@shop = Shop.find(params[:shop_id])
		@table = Table.find(params[:table_id])
		@table_girls = @table.table_girls
		categories = @shop.categories
		drink_category = categories.find_by(name:"ドリンク")
		shot_category = categories.find_by(name:"ショット")
		bottle_category = categories.find_by(name:"ボトル")
		any_category = categories.find_by(name:"その他")
		@drink_products = Product.where(category_id:[drink_category.id,shot_category.id])
		@bottle_products = Product.where(category_id:bottle_category.id)
		@any_products = Product.where(category_id:any_category.id)
		@table.orders.build
	end

	def create
		shop = Shop.find(params[:shop_id])
		table=Table.find(params[:table_id])

		params[:table][:orders_attributes].values.each do |param|
			if param[:today_girl_id] != nil
				if param[:quantity] != "0"
					girl = TodayGirl.find_by(id:param[:today_girl_id].to_i)
					product = Product.find_by(id:param[:product_id].to_i)
					girl.update(back_wage:girl.back_wage + (product.back_wage * param[:quantity].to_i))
					table.update(payment:table.payment + (product.price * param[:quantity].to_i).to_f)

					Order.create(product_id:product.id,table_id:table.id,quantity:param[:quantity].to_i)
				end
			else
				if param[:quantity] != "0"
					product = Product.find_by(id:param[:product_id].to_i)
					Order.create(product_id:product.id,table_id:table.id,quantity:param[:quantity].to_i)
					table.update(payment(table.payment + (product.price * param[:quantity].to_i).to_f)
				end
			end
		end

		redirect_to shop_top_path(shop.id)
	end
end