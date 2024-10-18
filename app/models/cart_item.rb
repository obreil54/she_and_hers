class CartItem < ApplicationRecord
  belongs_to :product
  belongs_to :cart
  validates :size, presence: true
end
