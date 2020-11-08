class Table < ApplicationRecord
	has_many :orders, dependent: :destroy
	accepts_nested_attributes_for :orders

	has_many :table_girls, dependent: :destroy
	accepts_nested_attributes_for :table_girls

	has_many :nameds, dependent: :destroy
	accepts_nested_attributes_for :nameds
	belongs_to :today

	validates :number, uniqueness: {scope: :today}
	has_many :products, through: :orders
	enum tax:{
		tax_cat:true,
		with_tax:false
	}

	enum payment_method:{
		cash:0,
		card:1,
		and_card:2
	}

	def self.table_create(shop,params)
		#入店処理
		if  params[:table][:nameds_attributes].values[0].value?("")
			#指名がなかった場合
			table = Table.new(number:params[:table][:number],member:params[:table][:member],price:params[:table][:price],tax:params[:table][:tax],set_time:params[:table][:set_time],name:params[:table][:name],memo:params[:table][:memo])
		else
			table = Table.new(table_params)
		end
		table.today_id = shop.today.id
		table.set_count = 1
		table.save!
		table.nameds.each do |named|
			#空の指名テーブルを削除
			if named.today_girl_id == nil
				named.destroy!
			end
		end
	end

	def self.occurrence_table(shop,table,params,table_params)
		table.update!(table_params)
			#料金発生時間を保存
			set_price = table.price * table.member
			#セット料金を計算
			#指名料（指名があった場合は後述のプログラムで指名料を計算）

			params[:table][:table_girls_attributes].values.each do |param|
				if TableGirl.find_by(today_girl_id:param[:"today_girl_id"]) != nil
					#発生で使うキャストがすでに他の卓についていた場合
					table_girl = TableGirl.find_by(today_girl_id:param[:"today_girl_id"])
					table_girl.update!(today_girl_id: nil)
					#既についていた卓を空状態にする。
				end
				TableGirl.create!(table_id:table.id,today_girl_id:param[:"today_girl_id"])
			end

			named_price = 0
			table.nameds.each do |named|
				#指名バックの計算+指名料の計算（ファーストセット分）
				today_girl = named.today_girl
				#出勤キャストの指名バックを加算
				if named.named_status_i18n == "本指名"
					back_wage = today_girl.back_wage
					today_girl.update!(back_wage:back_wage + shop.name_back)
					named_price += shop.name_price
				elsif named.named_status_i18n == "同伴"
				#同伴の場合
				back_wage = today_girl.back_wage
				today_girl.update!(back_wage:back_wage + shop.accompany_back)
					if shop.accompany_system_i18n == "同伴料金に指名料を含める"
						#同伴料金に指名料を含める場合
						named_price += shop.accompany
					else
						#同伴料金と別で指名料が発生する場合
						named_price += shop.accompany + shop.name_price
						Named.create!(table_id:table.id,today_girl_id:today_girl.id,named_status:"named")
					end
				elsif named.named_status_i18n == "場内"
					back_wage = today_girl.back_wage
					today_girl.update!(back_wage:back_wage + @shop.hall_back)
					named_price += shop.hall_price
				end
			end
			payment = named_price + set_price
			table.update!(payment:payment)
		end

		def self.extension_table(shop,table,nameds)
			named_price = 0
			unless nameds == []

				nameds.each do |named|
					if named.named_status_i18n == "本指名"
						named_price += shop.name_price
					elsif named.named_status_i18n == "場内"
						named_price += shop.hall_price
					end

				end

			end

			if shop.accompany_system_i18n == "同伴料金に指名料を含める"
				#店舗システムが同伴料金に指名料を含めるシステムの場合
				if table.set_count == 1
					#セットカウントが1の場合、延長時の同伴キャストの指名料を計算するための処理（２セット目以降は本指名レコードが存在する）
					accompany_nameds = table.nameds.where(named_status:"accompany")
					#同伴レコードを全て取得
					named_price += shop.name_price * accompany_nameds.count
					#指名料合計に指名料を加算
				end
			end

			return (shop.set_price + shop.extension_price) * table.member + named_price
		end


		def self.extensioning_table(shop,table,set_count,params)
			if shop.accompany_system_i18n == "同伴料金に指名料を含める"
					#同伴料金に指名料も含んでいる場合、料金、バック計算用の本指名テーブルを作成する
				if table.set_count == 1
					#セットカウントが１の時のみ新規作成処理
					accompany_nameds = table.nameds.where(named_status:1)
					#同伴テーブルを全て取得
					accompany_nameds.each do |accompany_named|
					#本指名レコードを新規作成
						Named.create!(today_girl_id:accompany_named.today_girl_id , table_id:accompany_named.table_id ,named_status:0,count:1)
					end
				end
			end

			table.table_girls.each do |table_girl|
				#延長するごとに、Named=>指名カウント、TodayGirl=>指名バック を加算
				if table_girl.today_girl_id != nil
					#キャストが接客中の場合、指名の有無を確認
					today_girl = TodayGirl.find_by(id:table_girl.today_girl_id)
					nameds = table.nameds.where(today_girl_id:today_girl.id)

					unless nameds == []
						#指名があった場合同伴レコードを除外
						without_accompany_nameds = nameds.where.not(named_status:1)

						without_accompany_nameds.each do |named|

							if named.named_status_i18n == "場内"
								#場内指名の場合のバックの計算＋指名カウントの更新
								add_back_wage = today_girl.back_wage + shop.hall_back
								today_girl.update!(back_wage:add_back_wage)
								add_count = named.count + 1
								named.update!(count:add_count)

							elsif named.named_status_i18n == "本指名"
								#本指名の場合のバックの計算＋指名カウントの更新
								add_back_wage = today_girl.back_wage + shop.name_back
								today_girl.update!(back_wage:add_back_wage)
								add_count = named.count + 1
								named.update!(count:add_count)
							end
						end
					end
				end
			end
			table.update!(set_count: set_count ,payment: params[:table][:payment])
			#hidden_fieldでPOSTされたhashで指名料＋延長料金を更新
		end

		def self.calculate_tax(shop,table,payment,card_payment)
			if table.tax_i18n == "TAX別"
				tax = payment * shop.tax
				#現金会計金額のTAX
				card_tax = card_payment * shop.tax
				#カード会計のTAX
				card_fee = (card_payment + card_tax) * shop.card_tax
				#カード会計時のカード手数料
			elsif table.tax_i18n == "TAXカット"
				if table.payment_method_i18n == "カード併用"
					#タックスカットの場合
					tax = (payment - (table.price * table.member)) * shop.tax
					card_tax = card_payment * shop.tax
					card_fee = (card_payment + card_tax) * shop.card_tax

				else
					tax = (payment - (table.price * table.member)) * shop.tax
					#ファーストセットのタックスを減算
					card_tax = (card_payment - (table.price * table.member)) * shop.tax
					card_fee = (card_payment + card_tax) * shop.card_tax

					if tax < 0
						tax = 0
					elsif card_tax < 0
						card_tax = 0
						card_fee = 0
					end
				end
			end
			return tax,card_tax,card_fee
		end

		def change_payment_method(shop,table,params)
			if table.payment_method_i18n == "現金払い"
				table.update(payment:params[:table][:all_payment].to_f / (1.0+shop.tax))

			elsif table.payment_method_i18n == "カード払い"
				table.update(card_payment:params[:table][:all_payment].to_f / (1.0 + shop.card_tax) / (1.0 + shop.tax))

			elsif table.payment_method_i18n == "カード併用"
				table.update(payment:params[:table][:payment].to_f / (1.0 + shop.tax))
				table.update(card_payment:params[:table][:card_payment].to_f / (1.0 + shop.card_tax) / (1.0 + shop.tax))
			end
		end

		def self.checkout_and_todaygrade_update(all_cash_payment,all_card_payment,today_grade,today,table,mounth,shop)
			cash_sale = all_cash_payment + today_grade.sale
			card_sale = all_card_payment + today_grade.card_sale
			#日別集計に売り上げを保存
			today_grade.update!(sale:cash_sale,card_sale:card_sale)
			#日別成績を更新

			today_girls = today.today_girls
			#出勤キャスト配列
			#下記から、指名キャストに売り上げデータを保存する処理
			all_sale = all_cash_payment + all_card_payment
			#テーブルの合計金額
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
						 if girl.sale > shop.slide_line
						 	#出勤キャストの今日の売り上げが、スライドラインを超えていた場合
						 	slide_count = (girl.sale / shop.slide_line).floor
						 	#スライドカウントを計算（何回スライドするかの回数）
							sliding_wage = girl.slide_wage + (shop.slide_wage * slide_count)
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




end
