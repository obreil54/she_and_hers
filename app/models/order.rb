class Order < ApplicationRecord
  monetize :total_amount_cents, allow_nil: false, numerically: { greater_than_or_equal_to: 0 }
  belongs_to :user, optional: true
  has_many :order_items, dependent: :destroy
  accepts_nested_attributes_for :order_items

  def total_price
    total = order_items.joins(:product).sum do |item|
      item.product.price_cents * item.quantity
    end
    Money.new(total, 'GBP')
  end
end
