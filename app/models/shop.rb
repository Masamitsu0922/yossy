class Shop < ApplicationRecord

	has_many :owners, through: :owner_shops
	has_many :owner_shops, dependent: :destroy
	accepts_nested_attributes_for :owner_shops

	has_many :categories, dependent: :destroy
	has_one :today, dependent: :destroy
	has_many :girls, dependent: :destroy
	has_many :catchs, dependent: :destroy
	has_many :staffs, dependent: :destroy
	has_many :mounth_grades, dependent: :destroy
	validates :shop_id, uniqueness: true
	validates :shop_id, presence: true
	validates :name,presence: true

	enum accompany_system:{
		with_name:0,
		without_name:1
	}
	def self.create_shop(owner,shop_params)
		#店舗情報の保存
		shop=Shop.new(shop_params)
		shop.save!
		# true/false
		#オーナーと紐づく中間テーブルの作成
		owner_shop=OwnerShop.new(owner_id:owner.id,shop_id:shop.id,is_authority:"master_owner")
		owner_shop.save!

		#初期設定：店舗に紐づく月度成績と日付テーブルの作成
		mounth = MounthGrade.new(shop_id:shop.id,mounth: Date.today.month)
		mounth.save!

		today = Today.new(shop_id:shop.id,date:Date.today.day,mounth_grade_id:mounth.id)
		today.save!

		TodayGrade.create!(mounth_grade_id:mounth.id,date:today.date,sale:0,card_sale:0)
		return shop.id
	end
	def self.setting_shop_detial(shop,shop_params)
		shop.update!(shop_params)
		drink_category=Category.create!(shop_id: shop.id,name: "ドリンク")
		shot_category=Category.create!(shop_id: shop.id,name: "ショット")
		bottle_category=Category.create!(shop_id: shop.id,name: "ボトル")
		any_category=Category.create!(shop_id: shop.id,name: "その他")

		Product.create!(category_id: drink_category.id, name: "キャストドリンク", back_wage:shop.drink_back, price: shop.drink)
		Product.create!(category_id: shot_category.id, name: "ショット", back_wage:shop.shot_back, price: shop.shot)
	end

end
