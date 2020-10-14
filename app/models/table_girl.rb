class TableGirl < ApplicationRecord
	belongs_to :today_girl, optional: true
	belongs_to :table
end
