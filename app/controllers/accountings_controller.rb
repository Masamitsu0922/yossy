class AccountingsController < ApplicationController

	before_action :set_shop_status

	def new
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
		@table = Table.find(params[:table_id])
	end

	def update
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
		table = Table.find(params[:table_id])
		today = table.today
		mounth = today.mounth_grade
		today_grade = TodayGrade.find_by(mounth_grade_id:mounth.id,date: today.date)

		cash_sale = table.payment * @shop.tax + table.payment + today_grade.sale.to_f
		card_sale = (table.card_payment * @shop.tax + table.card_payment) * @shop.card_tax + table.card_payment + today_grade.card_sale.to_f
		#日別集計に売り上げを保存
		today_grade.update(sale:cash_sale,card_sale:card_sale)

		#テーブル情報を削除
		table.destroy
		redirect_to shop_top_path(@shop.id)
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

end
