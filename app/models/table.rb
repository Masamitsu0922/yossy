class Table < ApplicationRecord
	has_many :orders, dependent: :destroy
	accepts_nested_attributes_for :orders

	has_many :table_girls, dependent: :destroy
	accepts_nested_attributes_for :table_girls

	has_many :nameds, dependent: :destroy
	accepts_nested_attributes_for :nameds
	belongs_to :today

	validates :number,uniqueness: true
end
