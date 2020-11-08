class Named < ApplicationRecord
	belongs_to :table
	belongs_to :today_girl

	enum named_status:{
		named:0,
		accompany:1,
		hall:2
	}

end
