class Product < ApplicationRecord
  monetize :price_cents
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :colors
  has_one_attached :primary_photo
  has_one_attached :secondary_photo
  has_one_attached :tertiary_photo
  has_many_attached :other_photos
  validates :price, presence: true
  validates :description, presence: true
  validates :care_instructions, presence: true
  validates :name, presence: true, uniqueness: true
  validates :primary_photo, presence: true
  validates :secondary_photo, presence: true
  validates :tertiary_photo, presence: true
end
