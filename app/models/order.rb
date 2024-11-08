class Order < ApplicationRecord
  monetize :total_amount_cents
  monetize :shipping_cost_cents
  belongs_to :user, optional: true
  belongs_to :discount_code, optional: true
  has_many :order_items, dependent: :destroy
  accepts_nested_attributes_for :order_items
  validates :status, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, :last_name, :address_line1, :city, :postal_code, :country, presence: true
  validates :phone, presence: true, format: { with: /\A[+\d\s()-]{7,}\z/, message: "must be a valid phone number" }
  validates :checkout_session_id, uniqueness: true, allow_nil: true

  validates :tracking_number, uniqueness: true, allow_nil: true
  validates :tracking_status, presence: true, allow_nil: true
  validates :selected_provider, presence: true
  validates :selected_service_level, presence: true

  def total_price
    total = order_items.sum { |item| item.item_price.cents * item.quantity }
    Money.new(total, 'GBP')
  end

  def discounted_total
    total_with_shipping = total_price.cents + (shipping_cost_cents || 0)
    Money.new(total_with_shipping, 'GBP')
  end
end
