class AccountingsController < ApplicationController

	def new
		@shop = Shop.find(params[:shop_id])
		@table = Table.find(params[:table_id])
		@payment = @table.payment
		#現金会計税抜き
		@card_payment = @table.card_payment
		#カード会計税抜き
		@tax = @payment * @shop.tax
		#現金会計金額のTAX
		@card_tax = @card_payment * @shop.tax
		#カード会計のTAX
		@card_fee = (@card_payment + @card_tax) * @shop.card_tax
		#カード会計時のカード手数料
	end

	def edit
		@shop = Shop.find(params[:shop_id])
		@table = Table.find(params[:table_id])
	end

	def update
		@shop = Shop.find(params[:shop_id])
		@table = Table.find(params[:table_id])
		if @table.payment_method == 0
			@table.update(payment:params[:table][:all_payment].to_f / (1.0+@shop.tax))
		elsif @table.payment_method == 1
			@table.update(card_payment:params[:table][:all_payment].to_f / (1.0 + @shop.card_tax) / (1.0+@shop.tax))
		elsif @table.payment_method == 2
			@table.update(payment:params[:table][:payment].to_f / (1.0+@shop.tax))
			@table.update(card_payment:params[:table][:card_payment].to_f / (1.0 + @shop.card_tax) / (1.0+@shop.tax))
		end
		redirect_to new_shop_table_accounting_path(@shop.id,@table.id)

	end

	def create
		@shop = Shop.find(params[:shop_id])
		@table = Table.find(params[:table_id])
		today = @table.today
		mounth = today.mounth_grade
		today.grade = TodayGrade.find_by(mounth_grade_id:mounth.id,date: today.date)
	end

end
