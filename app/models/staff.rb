class Staff < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
	devise :database_authenticatable,:authentication_keys => [:shop_id_for_sign,:id]

	#has_many :girls_grades, dependent: :destroy
  	belongs_to :shop
end
