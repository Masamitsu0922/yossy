class OwnerShop < ApplicationRecord
	#has_many :products, dependent: :destroy
	belongs_to :owner
	belongs_to :shop
end
