class MounthGrade < ApplicationRecord
	has_many :girls_grades, dependent: :destroy
	belongs_to :shop
end
