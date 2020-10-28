class TodayGradesController < ApplicationController

	before_action :check_user_basic
	#オーナー、スタッフどちらかログインしているか確認
	before_action :check_master_owner
	#マスターオーナーであるか確認

	def show
		@shop = Shop.find(params[:shop_id])
		@mounth_grade = MounthGrade.find(params[:mounth_grade_id])
		@today_grade = @mounth_grade.today_grades.find(params[:id])
		@payment = 0
		@today_grade.payments.each do |payment|
			@payment += payment.price
		end
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

end
