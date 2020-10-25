class TableGirl < ApplicationRecord
	belongs_to :today_girl, optional: true
	belongs_to :table
	#validates :today_girl_id#,uniqueness: true
end
