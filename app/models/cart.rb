class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def total_price
    total = cart_items.sum do |item|
      item.item_price.cents * item.quantity
    end
    Money.new(total, 'GBP')
  end
end
