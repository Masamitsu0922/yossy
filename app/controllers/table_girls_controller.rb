class TableGirlsController < ApplicationController
	before_action :check_user_basic
	#オーナー、スタッフどちらかログインしているか確認
	before_action :check_staff_leader
	#スタッフリーダーであるか確認
	before_action :check_master_owner
	#マスターオーナーであるか確認

	def update
		#場内指名アクション
		ActiveRecord::Base.transaction do
			shop = Shop.find(params[:shop_id])
			table_girl = TableGirl.find(params[:id])
			today_girl = table_girl.today_girl
			table = table_girl.table
			Named.create!(today_girl_id:today_girl.id,table_id:table.id,named_status:2)
			#新規指名レコードを作成

			#指名に伴う場内バックの計算
			add_hall_back =today_girl.back_wage + shop.hall_back
			today_girl.update!(back_wage:add_hall_back)

			#場内指名料金を会計に加算
			add_hall_price = table.payment + shop.hall_price
			table.update!(payment:add_hall_price)
		end

		redirect_to shop_top_path(params[:shop_id])

		rescue => e
			redirect_to redirect_to shop_top_path(params[:shop_id])
			flash[:alert] = "場内処理が正常に行われませんでした"
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
end
