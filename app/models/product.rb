class Product < ApplicationRecord
  monetize :price_cents
  monetize :original_price_cents, allow_nil: true

  attr_accessor :sale_price

  has_and_belongs_to_many :categories
  belongs_to :color
  has_one_attached :primary_photo
  has_one_attached :secondary_photo
  has_one_attached :tertiary_photo
  has_many_attached :other_photos
  has_many :wishlist_products
  has_many :wishlists, through: :wishlist_products
  has_many :cart_items
  has_many :order_items

  validates :price, presence: true
  validates :description, presence: true
  validates :care_instructions, presence: true
  validates :name, presence: true, uniqueness: true
  validates :primary_photo, presence: true
  validates :secondary_photo, presence: true
  validates :tertiary_photo, presence: true
  validates :weight, presence: true
  validates :one_size, inclusion: { in: [true, false] }
  validates :color, presence: true

  STATUSES = %w[available unavailable sold_out sale ready_to_ship hidden].freeze
  validates :status, inclusion: { in: STATUSES }

  before_save :handle_sale_price

  private

  def handle_sale_price
    return unless will_save_change_to_status?

    if status == "sale"
      self.original_price_cents ||= price_cents

      if sale_price.present?
        self.price_cents = (sale_price.to_f * 100).to_i
      end
    else
      if original_price_cents.present?
        self.price_cents = original_price_cents
        self.original_price_cents = nil
      end
    end
  end
end
