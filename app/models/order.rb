class Order < ApplicationRecord
	#has_many :girls_grades, dependent: :destroy
	belongs_to :product, optional: true
	belongs_to :table
end
