class OrdersController < ApplicationController
	before_action :check_user_basic
	#オーナー、スタッフどちらかログインしているか確認
	before_action :check_staff_leader
	#スタッフリーダーであるか確認
	before_action :check_master_owner
	#マスターオーナーであるか確認
	before_action :set_shop_status,except: :create

	def new
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

		ActiveRecord::Base.transaction do

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
						binding.pry
						table.update!(payment:add_payment)

						Order.create!(product_id:product.id,table_id:table.id,quantity:param[:quantity].to_i)
					end
				else
					if param[:quantity] != "0"
						#ドリンクやショット等のバックが発生しないオーダーを処理
						#数量が0以外の場合に処理を実行

						product = Product.find_by(id:param[:product_id].to_i)
						table.update!(payment:(table.payment + (product.price * param[:quantity].to_i).to_f))
						binding.pry
						Order.create!(product_id:product.id,table_id:table.id,quantity:param[:quantity].to_i)
					end
				end
			end
		end

		redirect_to shop_top_path(shop.id)

		rescue => e
		redirect_to new_shop_table_order_path(shop.id,table.id)
		flash[:alert] = "正常に保存できませんでした"

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
			unless current_staff.is_authority ==true
				redirect_to shop_top_path(params[:shop_id])
			end
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
end