class Product < ApplicationRecord
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :sizes
  has_and_belongs_to_many :colors
  has_one_attached :primary_photo
  has_one_attached :secondary_photo
  has_one_attached :tertiary_photo
  has_many_attached :other_photos
end
