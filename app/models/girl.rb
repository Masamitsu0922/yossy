class Girl < ApplicationRecord
	has_one :today_girl, dependent: :destroy
	has_many :girls_grades, dependent: :destroy
	has_one :today, through: :today_girls
	belongs_to :shop
end
