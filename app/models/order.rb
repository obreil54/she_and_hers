class Order < ApplicationRecord
  monetize :total_amount_cents, allow_nil: false, numerically: { greater_than_or_equal_to: 0 }
  belongs_to :user, optional: true
  has_many :order_items, dependent: :destroy
  accepts_nested_attributes_for :order_items
end
