class OrderItem < ApplicationRecord
  belongs_to :product
  belongs_to :order
  validates :product_id, :quantity, :size, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :size, length: { maximum: 50 }
end
