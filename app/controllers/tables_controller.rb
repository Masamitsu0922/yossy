class TablesController < ApplicationController

	before_action :set_shop_status

	def new
		@table = Table.new
		@table.nameds.build
		@girls = @shop.today.today_girls.where(attendance_status:1)

	end

	def create
		table = Table.new(table_params)
		table.today_id = @shop.today.id
		table.set_count = 1


		table.payment = table.price * table.member

		table.save
		table.nameds.each do |named|
			#空の指名テーブルを削除
			if named.today_girl_id == nil
				Named.find_by(id:named.id).destroy
			end
		end

		redirect_to shop_top_path(@shop.id)
	end

	def occurrence
		@table = Table.find(params[:id])
		@girls = @shop.today.today_girls.where(attendance_status:1)
		@table.table_girls.build
	end

	def occurrence_create
		@table = Table.find(params[:id].to_i)
		@table.update(table_params)


		params[:table][:table_girls_attributes].values.each do |param|
			if TableGirl.find_by(today_girl_id:param[:"today_girl_id"]) != nil
				#発生で使うキャストがすでに他の卓についていた場合
				table_girl = TableGirl.find_by(today_girl_id:param[:"today_girl_id"])
				table_girl.update(today_girl_id: nil)
			end
			TableGirl.create(table_id:@table.id,today_girl_id:param[:"today_girl_id"],name_status:0)
		end
		@table.nameds.each do |named|
			if TableGirl.finb_by(today_girl_id:named.today_girl_id,table_id:named.table_id) != nil
				named_girl = TableGirl.finb_by(today_girl_id:named.today_girl_id,table_id:named.table_id)

				#出勤キャストのバックを加算
				if named.named_status == 1
					back_wage =named_girl.table_girl.today_girl.back_wage
					named_girl.table_girl.today_girl.update(back_wage:back_wage + shop.name_back)
				elsif named.named_status == 2
					back_wage =named_girl.table_girl.today_girl.back_wage
					named_girl.table_girl.today_girl.update(back_wage:back_wage + shop.hall_back)
				elsif named.named_status == 3
					back_wage =named_girl.table_girl.today_girl.back_wage
					named_girl.table_girl.today_girl.update(back_wage:back_wage + shop.accompany_back)
				end
				named_girl.update.(name_status:named.named_status)
			end
		end
		redirect_to shop_top_path(@shop.id)
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
		@payment = (@shop.set_price + @shop.extension_price) * @table.member

		@table.table_girls.each do |table_girl|
			#延長するごとに指名料、指名バックを加算
			if table_girl.today_girl_id != nil
				today_girl = TodayGirl.find_by(id:table_girl.today_girl_id)
				if table_girl.name_status == 2
					@payment += @shop.hall_price
					today_girl.update(back_wage:today_girl.back_wage + @shop.hall_back)
				elsif table_girl.name_status == 1
					@payment += @shop.name_price
					today_girl.update(back_wage:today_girl.back_wage + @shop.name_back)
				elsif table_girl.name_status == 3
					@payment += @shop.accompany
					table_girl.update(named_status: 2)
					today_girl.update(back_wage:today_girl.back_wage + @shop.name_back)
				end
			end
		end
	end

	def extensioning
		shop = Shop.find(params[:shop_id])
		table = Table.find(params[:id])
		set_count=table.set_count+1
		table.update(set_count: set_count ,payment: params[:table][:payment])
		redirect_to shop_table_path(shop.id,table.id)
	end

	def card
		@table = Table.find(params[:id])
		@table.update(card_payment: @table.payment + @table.card_payment)
		@table.update(payment_method: 1,payment: 0)
		redirect_to new_shop_table_accounting_path(@shop.id,@table.id)
	end

	def and_card
		@table = Table.find(params[:id])
	end

	def and_carding
		@table = Table.find(params[:id])
		@table.update(card_payment: params[:table][:card_payment].to_f / (1.0+@shop.tax))
		@table.update(payment:@table.payment - @table.card_payment,payment_method: 2)
		redirect_to new_shop_table_accounting_path(@shop.id,@table.id)
	end

	def cash
		@table = Table.find(params[:id])
		@table.update(payment: @table.payment+@table.card_payment)
		@table.update(payment_method: 0,card_payment: 0)
		redirect_to new_shop_table_accounting_path(@shop.id,@table.id)
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

		def table_params
			params.require(:table).permit(:number,:today_id,:member,:time,:price,:set_time,:set_count,:payment,:name,:memo,:tax,:card_payment,nameds_attributes:[:today_girl_id,:table_id,:named_status])
		end

end
