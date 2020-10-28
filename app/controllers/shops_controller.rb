class ShopsController < ApplicationController

	before_action :check_user_basic
	#オーナー、スタッフどちらかログインしているか確認
	before_action :authenticate_owner!,only: [:index,:new,:create,:detial,:setting,:add,:adding]
	#その店舗のスタッフであるか買う人
	before_action :check_staff_leader,only: [:roll,:rolling]
	#スタッフリーダーであるか確認
	#閲覧オーナーであるか確認
	before_action :check_master_owner,only: [:detial,:setting,:destroy]
	#マスターオーナーであるか確認
	before_action :set_shop_status,except: [:index,:new,:create,:add,:adding]

	def index
		@owner=current_owner
	end

	def new
		@shop=Shop.new

	end

	def create
		if params[:passward] == params[:passward_verification]
			ActiveRecord::Base.transaction do
				#店舗情報の保存
				@shop=Shop.new(shop_params)
				@shop.save! # true/false
				#オーナーと紐づく中間テーブルの作成
				owner_shop=OwnerShop.new(owner_id:current_owner.id,shop_id:@shop.id,is_authority:true)
				owner_shop.save
				#初期設定：店舗に紐づく月度成績と日付テーブルの作成
				mounth = MounthGrade.new(shop_id:@shop.id,mounth: Date.today.month)
				mounth.save
				today = Today.new(shop_id:@shop.id,date:Date.today.day,mounth_grade_id:mounth.id)
				today.save
				TodayGrade.create(mounth_grade_id:mounth.id,date:today.date,sale:0,card_sale:0)
			rescue
			end

			redirect_to shop_detial_path(@shop.id)
		else
			redirect_to 'shops#new'
		end
	end

	def detial
	end

	def setting
		@shop.tax = params[:shop][:tax_percentage].to_f / 100
		@shop.card_tax = params[:shop][:card_tax_percentage].to_f / 100
		@shop.update(shop_params)
		drink_category=Category.create(shop_id: @shop.id,name: "ドリンク")
		shot_category=Category.create(shop_id: @shop.id,name: "ショット")
		bottle_category=Category.create(shop_id: @shop.id,name: "ボトル")
		any_category=Category.create(shop_id: @shop.id,name: "その他")

		Product.create(category_id: drink_category.id, name: "キャストドリンク", back_wage:@shop.drink_back, price: @shop.drink)
		Product.create(category_id: shot_category.id, name: "ショット", back_wage:@shop.shot_back, price: @shop.shot)

		redirect_to shops_path(current_owner.id)
	end

	def add
		@owner_shop = OwnerShop.new
	end

	def adding
		if shop = Shop.find_by(shop_id:params[:owner_shop][:shop_id])
			if shop.password == params[:owner_shop][:password]
				OwnerShop.create(owner_id:current_owner.id,shop_id:shop.id,is_authority: false)
				redirect_to shops_path
			else
				redirect_to shops_add_path
			end
		else
			redirect_to shops_add_path
		end
	end

	def top
		if @shop.today != nil
			if @shop.today.today_girls != nil
				@today_girls = @shop.today.today_girls.where(attendance_status: 1)
			end
			@tables = @shop.today.tables

		@costomers = 0
		@tables.each do |table|
			@costomers += table.member
		end
		@mounth_grade = MounthGrade.find_by(id:@shop.today.mounth_grade_id)
		@today_grade = TodayGrade.find_by(date:@shop.today.date)
		end
	end

	def roll
		@today = @shop.today
		@tables = @shop.today.tables
		@girls = @shop.today.today_girls.where(attendance_status: 1)
		@table_girls = @tables.map(&:table_girls)
	end

	def rolling
		today = @shop.today

		if today.update(today_params)

			redirect_to shop_top_path(@shop.id)
		else
			redirect_to shop_roll_path(@shop.id)
		end
	end

	def destroy
		@shop.destroy
		redirect_to shops_path
	end

	def release
		shop = @shop.owner_shops.find_by(owner_id:current_owner_id)
		shop.destroy
		redirect_to shops_path

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
				redirect_to shop_top_path(params[:id])
			end
		end

	end

	def check_master_owner
		if owner_signed_in?
			unless current_owner.owner_shops.find_by(shop_id:params[:id]).is_authority == true
				redirect_to shops_path(current_owner.id)
			end
		end
	end

	def set_shop_status
		@shop=Shop.find(params[:id])
		if @shop.today != nil
			if @shop.today.today_girls != nil
				@today_girls = @shop.today.today_girls.where(attendance_status: 1)
			end
			@mounth_grade = MounthGrade.find_by(id:@shop.today.mounth_grade_id)
			@today_grade = TodayGrade.find_by(date:@shop.today.date)
		end
	end

	def shop_params
		params.require(:shop).permit(:name,:postal_code,:address,:email,:shop_id,:password,:girl_wage,
			:staff_wage,:set_price,:extension_price,:name_price,:hall_price,:accompany,:drink,:shot,:tax,:acconpany_system,
			:table,:vip,:drink_back,:shot_back,:bottle_back,:name_back,:hall_back,:slide_line,:slide_wage,
			:deadline,:payment_date,owner_shops_attributes: [:id, :shop_id, :owner_id ,:is_authority])
	end

	def today_params
		params.require(:today).permit(tables_attributes:[:id,table_girls_attributes:[:id,:today_girl_id]])
	end
end