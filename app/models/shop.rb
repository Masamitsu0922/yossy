class Shop < ApplicationRecord
	has_many :owner_shop, dependent: :destroy
	has_many :categories, dependent: :destroy
	has_many :todays, dependent: :destroy
	has_many :girls, dependent: :destroy
	has_many :catchs, dependent: :destroy
	has_many :staffs, dependent: :destroy
	has_many :mounth_grades, dependent: :destroy

	#belongs_to :customer
end
