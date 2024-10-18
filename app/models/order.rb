class Order < ApplicationRecord
  monetize :total_amount_cents
  belongs_to :user, optional: true
  has_many :order_items, dependent: :destroy
  accepts_nested_attributes_for :order_items
end
