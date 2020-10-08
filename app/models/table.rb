class Table < ApplicationRecord
	has_many :orders, dependent: :destroy
	has_many :table_girls, dependent: :destroy
	belongs_to :today
end
