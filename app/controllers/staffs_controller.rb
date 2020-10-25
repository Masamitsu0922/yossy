class StaffsController < ApplicationController
	def index
		@shop = Shop.find(params[:shop_id])
		@staff = Staff.new
		@staffs = @shop.staffs
	end

	def create
		@shop = Shop.find(params[:shop_id])
		staff = Staff.new(staff_params)
		binding.pry
		staff.save
		redirect_to shop_staffs_path(@shop.id)
	end

	private

	def staff_params
		params.require(:staff).permit(:name,:wage,:is_authority,:password,:shop_id, :shop_id_for_sign)
	end
end
