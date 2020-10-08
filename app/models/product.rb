class Product < ApplicationRecord
	has_many :orders
	belongs_to :category
end
