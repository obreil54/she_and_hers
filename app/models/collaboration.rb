class Collaboration < ApplicationRecord
  has_many_attached :images
  has_one_attached :primary_image

  validates :name, presence: true
  validates :description, presence: true
end
