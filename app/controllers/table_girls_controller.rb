class TableGirlsController < ApplicationController
	before_action :check_user_basic
	#オーナー、スタッフどちらかログインしているか確認
	before_action :check_staff_leader
	#スタッフリーダーであるか確認
	before_action :check_master_owner
	#マスターオーナーであるか確認

	def update
		shop = Shop.find(params[:shop_id])
		table_girl = TableGirl.find(params[:id])
		table_girl.update(name_status:2)
		today_girl = table_girl.today_girl
		hall_back =today_girl.back_wage + shop.hall_back
		today_girl.update(back_wage:hall_back)
		redirect_to shop_top_path(params[:shop_id])
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
end
