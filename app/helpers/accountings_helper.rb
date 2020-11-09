module AccountingsHelper

	def set_price(table)
		table.price * table.member
	end

	def extension_price(shop)
		shop.set_price + shop.extension_price
	end

	def all_extension_price(shop,table)
		(shop.set_price + shop.extension_price) * table.member
	end

	def set_order_drinks(shop,table)
		drink_category = shop.categories.find_by(name: "ドリンク")
		drinks= Product.where(category_id: drink_category.id)
		order_drinks = table.orders.where(product_id: drinks.pluck(:id))
		drink_total_quantity = 0
		order_drinks.each do |drink|
			drink_total_quantity += drink.quantity
		end
		return drink_total_quantity
	end

	def set_order_shots(shop,table)
		shot_category = shop.categories.find_by(name: "ショット")
		shots= Product.where(category_id: shot_category.id)
		order_shots = table.orders.where(product_id: shots.pluck(:id))
		shot_total_quantity = 0
		order_shots.each do |shot|
			shot_total_quantity += shot.quantity
		end
		return shot_total_quantity
	end

	def set_order_bottle(shop,table)
		bottle_category = shop.categories.find_by(name: "ボトル")
		bottles= Product.where(category_id: bottle_category.id)
		order_bottles = table.orders.where(product_id: bottles.pluck(:id))
		return order_bottles
	end

	def set_order_any(shop,table)
		any_category = shop.categories.find_by(name: "その他")
		anys= Product.where(category_id: any_category.id)
		order_anys = table.orders.where(product_id: anys.pluck(:id))
		return order_anys
	end

	def all_payment_set(tax,payment,card_payment,card_tax,card_fee)
		all_cash_payment = (tax + payment).round.to_i
		all_card_payment = (card_payment + card_tax + card_fee).round.to_i
		return all_cash_payment,all_card_payment
	end
end
