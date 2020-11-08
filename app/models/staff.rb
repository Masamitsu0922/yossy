class Staff < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
	devise :database_authenticatable,:authentication_keys => [:shop_id_for_sign,:name]
	validates :name, uniqueness: {scope: :shop}

	#has_many :girls_grades, dependent: :destroy
  	belongs_to :shop

  	enum is_authority:{
		leader:true,
		staff:false
	}
end
