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

		#会計情報を日別成績モデルに保存する
		table = Table.find(params[:table_id])

		payment = table.payment
		#現金会計税抜き
		card_payment = table.card_payment
		#カード会計税抜き
		tax = payment * @shop.tax
		#現金会計金額のTAX
		card_tax = card_payment * @shop.tax
		#カード会計のTAX
		card_fee = (card_payment + card_tax) * @shop.card_tax

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

			cash_sale = all_cash_payment + today_grade.sale
			card_sale = all_card_payment + today_grade.card_sale
			all_sale = all_cash_payment + all_card_payment
			#日別集計に売り上げを保存
			today_grade.update!(sale:cash_sale,card_sale:card_sale)
			#日別成績を更新

			today_girls = today.today_girls
			#出勤キャスト配列
			#下記から、指名キャストに売り上げデータを保存する処理
			today_girls.each do |girl|
			#出勤キャストごとに指定のテーブルで指名があるか確認（同一キャストが同一テーブル内で指名レコードを複数持つことがあるためtoday_girlsからの処理）
				nameds = girl.nameds
				unless nameds == []
					table_named = girl.nameds.find_by(table_id:table.id)
					#指定テーブル内に少なくとも１つ指名レコードを持っていることの確認
					unless table_named == nil
						#指名を受けていた場合、売り上げ情報の更新処理
						add_sale = girl.sale + all_sale
						girl.update!(sale:add_sale)
						 if girl.sale > @shop.slide_line
						 	#出勤キャストの今日の売り上げが、スライドラインを超えていた場合
						 	slide_count = (girl.sale / @shop.slide_line).floor
						 	#スライドカウントを計算（何回スライドするかの回数）
							sliding_wage = girl.slide_wage + (@shop.slide_wage * slide_count)
							#スライド後の時給を計算
							girl.update!(slide_wage:sliding_wage)
							#変更の更新
						end
					end
				end
			end
			#テーブル情報を削除
			table.destroy
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
