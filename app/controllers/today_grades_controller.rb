class TodayGradesController < ApplicationController
	def show
		@shop = Shop.find(params[:shop_id])
		@mounth_grade = MounthGrade.find(params[:mounth_grade_id])
		@today_grade = @mounth_grade.today_grades.find(params[:id])
		@payment = 0
		@today_grade.payments.each do |payment|
			@payment += payment.price
		end
	end
end
