class MounthGradesController < ApplicationController

	before_action :check_detial
	#店舗詳細情報が未入力の場合、詳細情報入力画面に飛ばす
	def index
		@shop = Shop.find(params[:shop_id])
		if @shop.today != nil
			if @shop.today.today_girls != nil
				@today_girls = @shop.today.today_girls.where(attendance_status: 1)
			end
			@mounth_grade = MounthGrade.find_by(id:@shop.today.mounth_grade_id)
			@today_grade = @mounth_grade.today_grades.find_by(date:@shop.today.date)
		end
		@day_grades = @mounth_grade.today_grades
	end

	private
	def check_detial
		@shop = Shop.find(params[:shop_id])
        if @shop.set_price == nil ||  @shop.name_price == nil || @shop.hall_price == nil || @shop.accompany == nil || @shop.drink == nil ||  @shop.shot == nil ||  @shop.tax == nil ||  @shop.card_tax == nil ||  @shop.accompany_system == nil ||  @shop.table == nil ||  @shop.vip == nil ||  @shop.vip_price == nil ||  @shop.drink_back == nil ||  @shop.shot_back == nil ||  @shop.bottle_back == nil ||  @shop.name_back == nil ||  @shop.hall_back == nil ||  @shop.slide_line == nil ||  @shop.slide_wage == nil ||  @shop.deadline == nil ||  @shop.payment_date == nil ||  @shop.extension == nil ||  @shop.extension_price == nil ||  @shop.accompany_back == nil
            redirect_to shop_detial_path(@shop.id)
            flash[:alert] = "未入力項目があります※半角入力（使用しない値には0を入力してください)"
        end
    end
end
