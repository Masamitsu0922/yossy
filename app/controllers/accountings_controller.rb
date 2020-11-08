class AccountingsController < ApplicationController

	before_action :check_user_basic
	before_action :check_staff_leader,only: [:roll,:rolling]
	before_action :check_master_owner,only: [:detial,:setting]
	before_action :set_shop_status

	def new
		@table = Table.find(params[:table_id])
		@payment = @table.payment
		#現金会計税抜き
		@card_payment = @table.card_payment
		#カード会計税抜き
		@tax,@card_tax,@card_fee = Table.calculate_tax(@shop,@table,@payment,@card_payment)
	end

	def edit
		@table = Table.find(params[:table_id])
	end

	def update
		@table = Table.find(params[:table_id])

		Table.change_payment_method(@shop,@table,params)

		redirect_to new_shop_table_accounting_path(@shop.id,@table.id)

	end

	def create

		#会計情報を日別成績モデルに保存する
		table = Table.find(params[:table_id])

		payment = table.payment
		#現金会計税抜き
		card_payment = table.card_payment
		#カード会計税抜き

		tax,card_tax,card_fee = Table.calculate_tax(@shop,table,payment,card_payment)

		all_cash_payment = (payment + tax).round.to_i
		#現金会計総合計
		all_card_payment = (card_payment + card_tax + card_fee).round.to_i
		#カード会計総合計（手数料込み）

		today = table.today
		#紐づく日付レコードを所得
		mounth = today.mounth_grade
		#間接的に紐づく月成績レコードを所得
		today_grade = mounth.today_grades.find_by(date:today.date)
		#月成績に紐づく日別成績を所得



		ActiveRecord::Base.transaction do
			#テーブル会計+日別成績反映処理
			Table.checkout_and_todaygrade_update(all_cash_payment,all_card_payment,today_grade,today,table,mounth,@shop)
		end

		redirect_to shop_top_path(@shop.id)

		rescue => e
			redirect_to new_shop_table_accounting_path(params[:shop_id],params[:table_id])
			flash[:alert] = "正常に処理できませんでした。サポートセンターにお問い合わせください"
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
				redirect_to shop_top_path(params[:id])
				flash[:alert] = "権限がありません"
			end
		end

	end

	def check_master_owner
		if owner_signed_in?
			unless current_owner.owner_shops.find_by(shop_id:params[:id]).is_authority_i18n == "マスターオーナー"
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

end
