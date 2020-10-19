class TablesController < ApplicationController
	def new
		@shop = Shop.find(params[:shop_id])
		@table = Table.new
		@table.nameds.build
		@girls = @shop.today.today_girls.map(&:girl)

	end

	def create
		shop = Shop.find(params[:shop_id])
		table = Table.new(table_params)
		table.today_id = shop.today.id
		#binding.pry
		table.set_count = 1
		table.time = Time.now
		#binding.pry
		table.save

		if table.nameds == []
			table.member.times do |i|
				table_girl = TableGirl.new(table_id: table.id,name_status: 0)
				table_girl.save
			end
		else
			table.nameds.each do |named|
				table_girl = TableGirl.new(today_girl_id: named.today_girl_id,table_id: table.id,name_status: 1)
				table_girl.save
			end
			free_member = table.member - table.nameds.count
			free_member.times do |i|
				table_girl = TableGirl.new(table_id: table.id,name_status: 0)
				table_girl.save
			end
		end
		redirect_to shop_top_path(shop.id)
	end

	def show
		@table=Table.find(params[:id])
		@shop=Shop.find(params[:shop_id])
		@table_girls = @table.table_girls
		@orders=@table.orders
	end

	def extension
		@table = Table.find(params[:id])
		@shop = Shop.find(params[:shop_id])
		@payment = @shop.set_price * @table.member

		@table.table_girls.each do |table_girl|
			if table_girl.today_girl_id != nil
				if table_girl.name_status == 1
					@payment += @shop.hall_price
				elsif table_girl.name_status == 2
					@payment += @payment + @shop.name_price
				elsif table_girl.name_status == 3
					@payment += @payment + @shop.accompany
					table_girl.update(named_status: 2)
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
		@shop = Shop.find(params[:shop_id])
		@table = Table.find(params[:id])
		@table.update(card_payment: @table.payment + @table.card_payment)
		@table.update(payment_method: 1,payment: 0)
		redirect_to new_shop_table_accounting_path(@shop.id,@table.id)
	end

	def and_card
		@shop = Shop.find(params[:shop_id])
		@table = Table.find(params[:id])
	end

	def and_carding
		@shop = Shop.find(params[:shop_id])
		@table = Table.find(params[:id])
		@table.update(card_payment: params[:table][:card_payment].to_f / (1.0+@shop.tax))
		@table.update(payment:@table.payment - @table.card_payment,payment_method: 2)
		redirect_to new_shop_table_accounting_path(@shop.id,@table.id)
	end

	def cash
		@shop = Shop.find(params[:shop_id])
		@table = Table.find(params[:id])
		@table.update(payment: @table.payment+@table.card_payment)
		@table.update(payment_method: 0,card_payment: 0)
		redirect_to new_shop_table_accounting_path(@shop.id,@table.id)
	end

	private

		def table_params
			params.require(:table).permit(:number,:today_id,:member,:time,:price,:set_time,:set_count,:payment,:name,:memo,:tax,:card_payment,nameds_attributes:[:today_girl_id,:table_id,:named_status])
		end

end
