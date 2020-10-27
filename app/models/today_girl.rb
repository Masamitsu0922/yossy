class TodayGirl < ApplicationRecord
	belongs_to :girl, optional: true
	belongs_to :today
	has_one :table_girl
end
