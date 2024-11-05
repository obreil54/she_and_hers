class CartItem < ApplicationRecord
  belongs_to :product
  belongs_to :cart
  validates :size, presence: true

  def item_price
    base_price = product.price
    base_price = base_price * 1.2 if size == "CUSTOM"
    base_price
  end
end
