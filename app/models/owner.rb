class Owner < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
    has_many :shops, through: :owner_shops
    has_many :owner_shops,dependent: :destroy
	#belongs_to :customer
end
