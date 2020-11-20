class TablesController < ApplicationController
	before_action :check_user_basic
	#オーナー、スタッフどちらかログインしているか確認
	before_action :check_staff_leader
	#スタッフリーダーであるか確認
	before_action :check_master_owner
	#マスターオーナーであるか確認
	before_action :set_shop_status

	before_action :check_detial
	#店舗詳細情報が未入力の場合、詳細情報入力画面に飛ばす

	def new
		@table = Table.new
		@table.nameds.build
		@girls = @shop.today.today_girls.where(attendance_status:1)

	end

	def create
		ActiveRecord::Base.transaction do
			Table.table_create(@shop,params,table_params)
		end

		redirect_to shop_top_path(@shop.id)

		rescue => e
			redirect_to new_shop_table_path(@shop.id)
			@table = Table.new
			@table.nameds.build
			@girls = @shop.today.today_girls.where(attendance_status:1)
			flash[:alert] = "入力情報に誤りがあります"

	end

	def occurrence
		@table = Table.find(params[:id])
		@girls = @shop.today.today_girls.where(attendance_status:1)
		@table.table_girls.build
	end

	def occurrence_create
		@table = Table.find(params[:id])

		ActiveRecord::Base.transaction do

			Table.occurrence_table(@shop,@table,params,table_params)

		end
		redirect_to shop_top_path(@shop.id)

		rescue => e
			redirect_to shop_table_occurrence_path(@shop.id,@table.id)
			flash[:alert] = "発生処理に失敗しました"
	end

	def show
		@table=Table.find(params[:id])
		@table_girls = @table.table_girls
		@orders=@table.orders
		drink_category = @shop.categories.find_by(name:"ドリンク")
		@drinks = @table.products.where(category_id:drink_category.id)
		shot_category = @shop.categories.find_by(name:"ショット")
		@shots = @table.products.where(category_id:shot_category.id)


	end

	def extension
		@table = Table.find(params[:id])
		#指名の有無の確認＋指名料計算
		nameds = @table.nameds.where("( named_status = ?) OR ( named_status = ?)", 0, 2)
		#道南レコードを除いた指名レコード全て取得

		@payment = Table.extension_table(@shop,@table,nameds)
		#延長料金を計算したものを変数に格納

	end

	def extensioning
		#延長アクション
		shop = Shop.find(params[:shop_id])
		table = Table.find(params[:id])
		set_count = table.set_count + 1

		ActiveRecord::Base.transaction do
			Table.extensioning_table(shop,table,set_count,params)
			#延長情報更新処理
		end

		redirect_to shop_table_path(params[:shop_id],params[:id])

		rescue => e
			redirect_to shop_table_extension_path(shop.id,table.id)
			flash[:alert] = "正常に処理できませんでした"
	end

	def card
		@table = Table.find(params[:id])
		ActiveRecord::Base.transaction do
			@table.update!(card_payment: @table.payment + @table.card_payment)
			@table.update!(payment_method: "card",payment: 0)
		end
		redirect_to new_shop_table_accounting_path(@shop.id,@table.id)
	end

	def and_card
		@table = Table.find(params[:id])
	end

	def and_carding
		@table = Table.find(params[:id])
		ActiveRecord::Base.transaction do
			@table.update!(card_payment: params[:table][:card_payment].to_f / (1.0+@shop.tax))
			@table.update!(payment:@table.payment - @table.card_payment,payment_method: "and_card")
		end
		redirect_to new_shop_table_accounting_path(@shop.id,@table.id)
	end

	def cash
		@table = Table.find(params[:id])
		ActiveRecord::Base.transaction do
			@table.update!(payment: @table.payment+@table.card_payment)
			@table.update!(payment_method: "cash",card_payment: 0)
		end
		redirect_to new_shop_table_accounting_path(@shop.id,@table.id)
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
			unless current_staff.is_authority_i18n == "スタッフリーダー"
				redirect_to shop_top_path(params[:shop_id])
				flash[:alert] = "権限がありません"
			end
		end

	end

	def check_master_owner
		if owner_signed_in?
			unless current_owner.owner_shops.find_by(shop_id:params[:shop_id]).is_authority_i18n == "マスターオーナー"
				redirect_to shops_path(current_owner.id)
				flash[:alert] = "権限がありません"
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
        	if @shop.set_price == nil ||  @shop.name_price == nil || @shop.hall_price == nil || @shop.accompany == nil || @shop.drink == nil ||  @shop.shot == nil ||  @shop.tax == nil ||  @shop.card_tax == nil ||  @shop.accompany_system == nil ||  @shop.table == nil ||  @shop.vip == nil ||  @shop.vip_price == nil ||  @shop.drink_back == nil ||  @shop.shot_back == nil ||  @shop.bottle_back == nil ||  @shop.name_back == nil ||  @shop.hall_back == nil ||  @shop.slide_line == nil ||  @shop.slide_wage == nil ||  @shop.deadline == nil ||  @shop.payment_date == nil || @shop.extension_price == nil ||  @shop.accompany_back == nil
            	redirect_to shop_detial_path(@shop.id)
    	        flash[:alert] = "未入力項目があります※半角入力（使用しない値には0を入力してください)"
        	end
    	end

		def table_params
			params.require(:table).permit(:number,:today_id,:member,:time,:price,:set_time,:set_count,:payment,:name,:memo,:tax,:card_payment,nameds_attributes:[:today_girl_id,:table_id,:named_status,:count])
		end

end
