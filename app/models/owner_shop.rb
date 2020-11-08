class OwnerShop < ApplicationRecord
	#has_many :products, dependent: :destroy
	belongs_to :owner
	belongs_to :shop
	enum is_authority:{
		master_owner:true,
		looking_owner:false
	}
end
