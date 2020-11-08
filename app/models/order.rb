class Order < ApplicationRecord
	#has_many :girls_grades, dependent: :destroy
	belongs_to :product, optional: true
	belongs_to :table

	def self.ready_order(shop,params)
		table = Table.find(params[:table_id])
		table_girls = table.table_girls
		categories = shop.categories
		drink_category = categories.find_by(name:"ドリンク")
		shot_category = categories.find_by(name:"ショット")
		bottle_category = categories.find_by(name:"ボトル")
		any_category = categories.find_by(name:"その他")
		drink_products = Product.where(category_id:[drink_category.id,shot_category.id])
		bottle_products = Product.where(category_id:bottle_category.id)
		any_products = Product.where(category_id:any_category.id)

		return table,table_girls,drink_products,bottle_products,any_products
	end

	def self.order_create(table,params)
		params[:table][:orders_attributes].values.each do |param|
			#tableに紐づいたorderハッシュを繰り返し処理
			if param[:today_girl_id] != nil
				#ドリンクやショット等のバックが発生するオーダーを処理
				if param[:quantity] != "0"
					#数量が0以外の場合に処理を実行
					girl = TodayGirl.find_by(id:param[:today_girl_id].to_i)
					product = Product.find_by(id:param[:product_id].to_i)
					add_back_wage = girl.back_wage + (product.back_wage * param[:quantity].to_i)
					add_payment = table.payment + (product.price * param[:quantity].to_i).to_f
					girl.update!(back_wage:add_back_wage)
					table.update!(payment:add_payment)

					Order.create!(product_id:product.id,table_id:table.id,quantity:param[:quantity].to_i)
				end
			else
				if param[:quantity] != "0"
					#ドリンクやショット等のバックが発生しないオーダーを処理
					#数量が0以外の場合に処理を実行

					product = Product.find_by(id:param[:product_id].to_i)
					table.update!(payment:(table.payment + (product.price * param[:quantity].to_i).to_f))
					Order.create!(product_id:product.id,table_id:table.id,quantity:param[:quantity].to_i)
				end
			end
		end
	end
end
