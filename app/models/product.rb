class Product < ApplicationRecord
	has_many :orders
	belongs_to :category
	has_many :tables, through: :orders
end
