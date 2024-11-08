class DiscountCode < ApplicationRecord
  validates :code, presence: true, uniqueness: true, length: { maximum: 20 }
  validates :discount_percentage, presence: true,
                                  numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 100 }
  validates :used, inclusion: { in: [true, false] }

  scope :unused, -> { where(used: false) }

  has_many :orders

  def mark_as_used
    update(used: true)
  end

  def self.generate_unique_code(discount_percentage)
    loop do
      code = SecureRandom.hex(4).upcase
      return create!(code: code, discount_percentage: discount_percentage, used: false) unless exists?(code: code)
    end
  end
end
