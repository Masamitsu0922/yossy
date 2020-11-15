class Today < ApplicationRecord
	has_many :tables, dependent: :destroy
	accepts_nested_attributes_for :tables
	has_many :today_girls, dependent: :destroy
	accepts_nested_attributes_for :today_girls
	belongs_to :shop
	belongs_to :mounth_grade

	def self.open_ready(shop,today,params)
		if today.date != params[:today][:date]
			today.update!(date:params[:today][:date].to_i)

			if shop.mounth_grades.find_by(mounth:Date.today.month) == nil
				month = MounthGrade.new(shop_id:shop.id,mounth:Date.today.month)
				month.save
				today.update!(mounth_grade_id:month.id)
				TodayGrade.create!(mounth_grade_id:month.id,date:today.date,sale:0,card_sale:0)
			else
				TodayGrade.create!(mounth_grade_id:today.mounth_grade_id,date:today.date,sale:0,card_sale:0)
			end
		end

		params[:today][:today_girls_attributes].values.each do |param|
			#集金キャストレコードの作成
			if param[:"girl_id"] != nil
				if param[:"girl_id"].to_i != 0
					#チェックが入っていない項目を処理から弾く（在籍キャストの処理）
				  	start_time = Time.local(param[:"start_time(1i)"],param[:"start_time(2i)"],param[:"start_time(3i)"],param[:"start_time(4i)"],param[:"start_time(5i)"])
			      	end_time = Time.local(param[:"end_time(1i)"],param[:"end_time(2i)"],param[:"end_time(3i)"],param[:"end_time(4i)"],param[:"end_time(5i)"])
			      	name = Girl.find_by(id: param[:"girl_id"].to_i).name
					today_girl = TodayGirl.new(sale:0,today_id: shop.today.id, girl_id: param[:"girl_id"].to_i,name: name, start_time: start_time,end_time: end_time,slide_wage: Girl.find_by(id:(param[:"girl_id"]).to_i).wage, destination: param[:"destination"], girl_status: "registry", today_payment: param[:"today_payment"])
					today_girl.save!
				end
			elsif param[:"girl_status"].to_i == 1 || param[:"girl_status"].to_i == 2
				#派遣ステータスが入力されている項目を処理する
				start_time = Time.local(param[:"start_time(1i)"],param[:"start_time(2i)"],param[:"start_time(3i)"],param[:"start_time(4i)"],param[:"start_time(5i)"])
			    end_time = Time.local(param[:"end_time(1i)"],param[:"end_time(2i)"],param[:"end_time(3i)"],param[:"end_time(4i)"],param[:"end_time(5i)"])
			    today_girl = TodayGirl.new(sale:0,name:param[:"name"],today_id: shop.today.id, start_time: start_time,end_time: end_time,slide_wage: param[:"slide_wage"], destination: param[:"destination"], girl_status: param[:"girl_status"].to_i, today_payment: param[:"today_payment"],is_all_today: param[:"is_all_today"])
			    today_girl.save!
			end
		end
	end

	def self.finish(shop)
		if Date.today.day != shop.today.date
			#営業中に日付が変わった場合
			day = Date.today.day

				if shop.mounth_grades.find_by(mounth:Date.today.month) == []
					#アクション中の日付を参照し対応する月度成績テーブルがなかった場合
					mounth = MounthGrade.new(shop_id:shop.id,mounth:Date.today.month)
					mounth.save!
					shop.mounth_grades.find_by(mounth:Date.today.month - 4).destroy
				else
					mounth = shop.mounth_grades.find_by(mounth:Date.today.month)
				end
			#month = Date.today.month
		elsif Date.today.day == shop.today.date
			#営業中に日付が変わらなかった場合
				if shop.mounth_grades.find_by(mounth:Date.tomorrow.month) == []
					#アクション中の翌日の日付を参照し対応する月度成績テーブルがなかった場合
					mounth = Mounth.new(shop_id:shop.id,mounth:Date.today.month)
					mounth.save!
					day = 1
					shop.mounth_grades.find_by(mounth:Date.tomorrow.month - 4).destroy
				else
					day = Date.today.day + 1
					mounth = shop.mounth_grades.find_by(mounth:Date.today.month)
				end
			#month = Date.today.month
		end

		shop.today.destroy


		Today.create(shop_id:shop.id, date:day,mounth_grade_id:mounth.id)
		TodayGrade.create(mounth_grade_id:mounth.id,date:day,sale:0,card_sale:0)
	end
end
