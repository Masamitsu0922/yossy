class StaffsController < ApplicationController
	before_action :check_user_basic
	#オーナー、スタッフどちらかログインしているか確認
	before_action :check_master_owner
	#マスターオーナーであるか確認
	before_action :set_shop_status

	def index
		@shop = Shop.find(params[:shop_id])
		@staff = Staff.new
		@staffs = @shop.staffs
	end

	def create
		@shop = Shop.find(params[:shop_id])
		staff = Staff.new(staff_params)
		staff.save
		redirect_to shop_staffs_path(@shop.id)
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

	def staff_params
		params.require(:staff).permit(:name,:wage,:is_authority,:password,:shop_id, :shop_id_for_sign)
	end
end
