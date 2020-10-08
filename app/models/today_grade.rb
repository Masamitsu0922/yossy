class TodayGrade < ApplicationRecord
	has_many :payments, dependent: :destroy
	belongs_to :mounth_grade
end
