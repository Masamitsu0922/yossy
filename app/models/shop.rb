class Shop < ApplicationRecord

	has_many :owners, through: :owner_shops
	has_many :owner_shops, dependent: :destroy
	accepts_nested_attributes_for :owner_shops

	has_many :categories, dependent: :destroy
	has_one :today, dependent: :destroy
	has_many :girls, dependent: :destroy
	has_many :catchs, dependent: :destroy
	has_many :staffs, dependent: :destroy
	has_many :mounth_grades, dependent: :destroy
	validates :shop_id, uniqueness: true

	#belongs_to :customer
end
