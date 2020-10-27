class Girl < ApplicationRecord
	has_one :today_girl, dependent: :destroy
	has_many :girl_grades
	belongs_to :shop
end
