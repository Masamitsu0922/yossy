class PaymentsController < ApplicationController
	def index
		@shop = Shop.find(params[:shop_id])
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
	def payment_params
		params.require(:payment).permit(:today_grade_id,:item,:name,:price,:memo)
	end
end
