class OrderItem < ApplicationRecord
  belongs_to :product
  belongs_to :order
  validates :product_id, :quantity, :size, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :size, length: { maximum: 50 }

  def item_price
    base_price = product.price_cents
    base_price = (base_price * 1.2).to_i if size == "CUSTOM"
    Money.new(base_price, 'GBP')
  end
end
