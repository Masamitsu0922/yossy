class MounthGrade < ApplicationRecord
	has_many :girls_grades, dependent: :destroy
	has_many :todays
	has_many :today_grades
	belongs_to :shop
end
