module GirlsHelper

	def set_girl_grade(girl,mounth_grade)
		girl_grade = 0
		girl.girl_grades.where(mounth_grade_id:mounth_grade.id).each do |grade|
			if grade.sale != nil
				girl_grade += grade.sale
			end
		end
		return girl_grade
	end
end
