class TableGirlsController < ApplicationController
	before_action :check_user_basic
	#オーナー、スタッフどちらかログインしているか確認
	before_action :check_staff_leader
	#スタッフリーダーであるか確認
	before_action :check_master_owner
	#マスターオーナーであるか確認
	before_action :check_detial
	#店舗詳細情報が未入力の場合、詳細情報入力画面に飛ばす

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

	def check_detial
		@shop = Shop.find(params[:shop_id])
        if @shop.set_price == nil ||  @shop.name_price == nil || @shop.hall_price == nil || @shop.accompany == nil || @shop.drink == nil ||  @shop.shot == nil ||  @shop.tax == nil ||  @shop.card_tax == nil ||  @shop.accompany_system == nil ||  @shop.table == nil ||  @shop.vip == nil ||  @shop.vip_price == nil ||  @shop.drink_back == nil ||  @shop.shot_back == nil ||  @shop.bottle_back == nil ||  @shop.name_back == nil ||  @shop.hall_back == nil ||  @shop.slide_line == nil ||  @shop.slide_wage == nil ||  @shop.deadline == nil ||  @shop.payment_date == nil || @shop.extension_price == nil ||  @shop.accompany_back == nil
            redirect_to shop_detial_path(@shop.id)
            flash[:alert] = "未入力項目があります※半角入力（使用しない値には0を入力してください)"
        end
    end
end
