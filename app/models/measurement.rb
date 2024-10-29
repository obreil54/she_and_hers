class Measurement < ApplicationRecord
  belongs_to :user

  validates :chest, :waist, :high_hips, :low_hips, :thigh, :torso, :arm_length,
            :shoulder_width, :upper_arm_circumference, :inseam, :height,
            numericality: { greater_than: 0 }, allow_nil: true
end
