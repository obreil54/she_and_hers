class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def total_price
    total = cart_items.joins(:product).sum do |item|
      item.product.price_cents * item.quantity
    end
    Money.new(total, 'GBP')
  end
end
