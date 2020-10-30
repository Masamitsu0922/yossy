class PaymentsController < ApplicationController

	before_action :check_user_basic
	#オーナーログインしているか確認
	before_action :check_master_owner
	#マスターオーナーであるか確認
	before_action :set_shop_status

	def index
		@today_grade = TodayGrade.find_by(date:@shop.today.date)
		@mounth_grade = @today_grade.mounth_grade
		@payments = @today_grade.payments
		@payment = Payment.new

	end

	def create
		@shop = Shop.find(params[:shop_id])
		@today_grade = TodayGrade.find_by(date:@shop.today.date)
		@mounth_grade = @today_grade.mounth_grade
		Payment.create(payment_params)
		redirect_to shop_mounth_grade_today_grade_payments_path(@shop.id,@mounth_grade.id,@today_grade.id)
	end

	private

	def check_user_basic
		if owner_signed_in?
		else
			redirect_to root_path
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

	def payment_params
		params.require(:payment).permit(:today_grade_id,:item,:name,:price,:memo)
	end
end
