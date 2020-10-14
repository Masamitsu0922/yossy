class Today < ApplicationRecord
	has_many :tables, dependent: :destroy
	accepts_nested_attributes_for :tables
	has_many :today_girls, dependent: :destroy
	belongs_to :shop
	has_many :girls, through: :today_girls
	accepts_nested_attributes_for :today_girls

end
