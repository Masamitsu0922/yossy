class TodayGirl < ApplicationRecord
	belongs_to :girl
	belongs_to :today
	has_one :table_girl
end
