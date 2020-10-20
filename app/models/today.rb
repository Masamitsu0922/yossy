class Today < ApplicationRecord
	has_many :tables, dependent: :destroy
	accepts_nested_attributes_for :tables
	has_many :today_girls, dependent: :destroy
	accepts_nested_attributes_for :today_girls
	belongs_to :shop
	belongs_to :mounth_grade

end
