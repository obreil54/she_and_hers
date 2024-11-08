class OrderItem < ApplicationRecord
  belongs_to :product
  belongs_to :order
  validates :product_id, :quantity, :size, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :size, length: { maximum: 50 }

  def item_price
    base_price = product.price_cents
    base_price = (base_price * 1.2).to_i if size == "CUSTOM"

    if order.discount_code
      discount_percentage = order.discount_code.discount_percentage
      base_price = (base_price * (1 - discount_percentage / 100.0)).to_i
    end

    Money.new(base_price, 'GBP')
  end
end
