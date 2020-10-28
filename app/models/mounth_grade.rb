class MounthGrade < ApplicationRecord
	has_many :girl_grades,dependent: :destroy
	has_many :todays
	has_many :today_grades, dependent: :destroy
	belongs_to :shop
end
