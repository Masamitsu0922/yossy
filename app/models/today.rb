class Today < ApplicationRecord
	has_many :tables, dependent: :destroy
	has_many :today_girls, dependent: :destroy
	belongs_to :shop
end
