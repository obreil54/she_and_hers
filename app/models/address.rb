class Address < ApplicationRecord
  belongs_to :user

  validates :address_line1, :city, :postal_code, :country, presence: true
  validates :address_line2, length: { maximum: 255 }, allow_blank: true
  validates :state, length: { maximum: 100 }, allow_blank: true
  validates :postal_code, length: { minimum: 3, maximum: 20 }
  validates :country, length: { maximum: 100 }

end
