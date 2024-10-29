class Order < ApplicationRecord
  monetize :total_amount_cents
  monetize :shipping_cost_cents
  belongs_to :user, optional: true
  has_many :order_items, dependent: :destroy
  accepts_nested_attributes_for :order_items
  validates :status, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, :last_name, :address_line1, :city, :postal_code, :country, presence: true
  validates :phone, presence: true, format: { with: /\A[+\d\s()-]{7,}\z/, message: "must be a valid phone number" }
  validates :checkout_session_id, uniqueness: true, allow_nil: true

  def total_price
    total = order_items.joins(:product).sum do |item|
      item.product.price_cents * item.quantity
    end
    Money.new(total, 'GBP')
  end
end
