module MounthGradesHelper
	def day_payment_set(grade)
		day_payment = 0
		grade.payments.each do |payment|
			day_payment += payment.price
		end
		return day_payment
	end
end
