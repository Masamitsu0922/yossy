class Girl < ApplicationRecord
	has_many :today_girls, dependent: :destroy
	has_many :girls_grades, dependent: :destroy
	belongs_to :shop
end
