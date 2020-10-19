class OrdersController < ApplicationController
	def new
		@shop = Shop.find(params[:shop_id])
		@order = Order.new
		@table = Table.find(params[:table_id])
		@table_girls = @table.table_girls
		@categories = @shop.categories
	end

	def create
		shop = Shop.find(params[:shop_id])
		table=Table.find(params[:table_id])

		drink_order = Order.new(table_id:table.id,quantity:params[:order][:drink_count])

		if params[:order][:drink_id] == "1"
			drink_payment = shop.drink * drink_order.quantity
		elsif params[:order][:drink_id] == "2"
			drink_payment = shop.shot * drink_order.quantity
		end

		table.update(payment: table.payment + drink_payment)
		#バック金額に関する処理
		drink_order.save

		bottle_order = Order.new(product_id:params[:order][:bottle_name],table_id:table.id,quantity:params[:order][:bottle_count])
		bottle_product=Product.find_by(id: params[:order][:bottle_name])
		bottle_payment = bottle_product.price * bottle_order.quantity
		table.update(payment: table.payment + bottle_payment)
		bottle_order.save

		any_order = Order.new(product_id:params[:order][:any_name],table_id:table.id,quantity:params[:order][:any_count])
		any_product=Product.find_by(id: params[:order][:any_name])
		any_payment = any_product.price * any_order.quantity
		table.update(payment: table.payment + any_payment)
		any_order.save

		redirect_to shop_top_path(shop.id)
	end
end