class TablesController < ApplicationController
	before_action :check_user_basic
	#オーナー、スタッフどちらかログインしているか確認
	before_action :check_staff_leader
	#スタッフリーダーであるか確認
	before_action :check_master_owner
	#マスターオーナーであるか確認
	before_action :set_shop_status,except: [:extensioning]

	def new
		@table = Table.new
		@table.nameds.build
		@girls = @shop.today.today_girls.where(attendance_status:1)

	end

	def create
		ActiveRecord::Base.transaction do
			if  params[:table][:nameds_attributes].values[0].value?("")
				#指名がなかった場合
				table = Table.new(number:params[:table][:number],member:params[:table][:member],price:params[:table][:price],tax:params[:table][:tax],set_time:params[:table][:set_time],name:params[:table][:name],memo:params[:table][:memo])
			else
				table = Table.new(table_params)
			end
			table.today_id = @shop.today.id
			table.set_count = 1
			table.save!
			table.nameds.each do |named|
				#空の指名テーブルを削除
				if named.today_girl_id == nil
					named.destroy!
				end
			end
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
			@table.update!(table_params)
			#料金発生時間を保存
			set_price = @table.price * @table.member
			#セット料金を計算
			#指名料（指名があった場合は後述のプログラムで指名料を計算）

			params[:table][:table_girls_attributes].values.each do |param|
				if TableGirl.find_by(today_girl_id:param[:"today_girl_id"]) != nil
					#発生で使うキャストがすでに他の卓についていた場合
					table_girl = TableGirl.find_by(today_girl_id:param[:"today_girl_id"])
					table_girl.update!(today_girl_id: nil)
					#既についていた卓を空状態にする。
				end
				TableGirl.create!(table_id:@table.id,today_girl_id:param[:"today_girl_id"])
			end

			named_price = 0
			@table.nameds.each do |named|
				#指名バックの計算+指名料の計算（ファーストセット分）
				today_girl = named.today_girl
				#出勤キャストの指名バックを加算
				if named.named_status == 0
					back_wage = today_girl.back_wage
					today_girl.update!(back_wage:back_wage + @shop.name_back)
					named_price += @shop.name_price
				elsif named.named_status == 1
				#同伴の場合
				back_wage = today_girl.back_wage
				today_girl.update!(back_wage:back_wage + @shop.accompany_back)
					if @shop.accompany_system == 0
						#同伴料金に指名料を含める場合
						named_price += @shop.accompany
					else
						#同伴料金と別で指名料が発生する場合
						named_price += @shop.accompany + @shop.name_price
						Named.create(table_id:@table.id,today_girl_id:today_girl.id,named_status:0)
					end
				elsif named.named_status == 2
					back_wage = today_girl.back_wage
					today_girl.update!(back_wage:back_wage + @shop.hall_back)
					named_price += @shop.hall_price
				end
			end
			payment = named_price + set_price
			@table.update!(payment:payment)

		end
		redirect_to shop_top_path(@shop.id)

		rescue => e
			redirect_to shop_table_occurrence_path(@shop.id,@table.id)
			flash[:alert] = "保存に失敗しました"
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
		named_price = 0


		nameds = @table.nameds.where("( named_status = ?) OR ( named_status = ?)", 0, 2)
		#道南レコードを除いた指名レコード全て取得
		unless nameds == []

			nameds.each do |named|
				if named.named_status == 0
					named_price += @shop.name_price
				elsif named.named_status == 2
					named_price += @shop.hall_price
				end

			end

		end

		if @shop.accompany_system == 0
			#店舗システムが同伴料金に指名料を含めるシステムの場合
			if @table.set_count == 1
				#セットカウントが1の場合、延長時の同伴キャストの指名料を計算するための処理（２セット目以降は本指名レコードが存在する）
				accompany_nameds = @table.nameds.where(named_status:1)
				#同伴レコードを全て取得
				named_price += @shop.name_price * accompany_nameds.count
				#指名料合計に指名料を加算
			end
		end

		@payment = (@shop.set_price + @shop.extension_price) * @table.member + named_price

	end

	def extensioning
		#延長アクション
		ActiveRecord::Base.transaction do
			shop = Shop.find(params[:shop_id])
			table = Table.find(params[:id])
			set_count = table.set_count + 1

			if shop.accompany_system == 0
				#同伴料金に指名料も含んでいる場合、料金、バック計算用の本指名テーブルを作成する
				if @table.set_count == 1
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

							if named.named_status == 2
								#場内指名の場合のバックの計算＋指名カウントの更新
								add_back_wage = today_girl.back_wage + shop.hall_back
								today_girl.update!(back_wage:add_back_wage)
								add_count = named.count + 1
								named.update!(count:add_count)

							elsif named.named_status == 0
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
		redirect_to shop_table_path(params[:shop_id],params[:id])

		rescue => e
			redirect_to shop_table_extension_path(shop.id,table.id)
			flash[:alert] = "正常に処理できませんでした"
	end

	def card
		@table = Table.find(params[:id])
		ActiveRecord::Base.transaction do
			@table.update!(card_payment: @table.payment + @table.card_payment)
			@table.update!(payment_method: 1,payment: 0)
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
			@table.update!(payment:@table.payment - @table.card_payment,payment_method: 2)
		end
		redirect_to new_shop_table_accounting_path(@shop.id,@table.id)
	end

	def cash
		@table = Table.find(params[:id])
		ActiveRecord::Base.transaction do
			@table.update!(payment: @table.payment+@table.card_payment)
			@table.update!(payment_method: 0,card_payment: 0)
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

		def table_params
			params.require(:table).permit(:number,:today_id,:member,:time,:price,:set_time,:set_count,:payment,:name,:memo,:tax,:card_payment,nameds_attributes:[:today_girl_id,:table_id,:named_status,:count])
		end

end
