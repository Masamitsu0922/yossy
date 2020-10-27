class GirlGrade < ApplicationRecord
	#has_many :girls_grades, dependent: :destroy
	belongs_to :mounth_grade
	belongs_to :girl, optional: true
end
