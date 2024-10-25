class Address < ApplicationRecord
  belongs_to :user

  validates :address_line1, :city, :postal_code, :country, presence: true
end
