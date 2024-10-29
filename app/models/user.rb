class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  after_create :create_measurement

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :terms_of_service, acceptance: { message: 'MUST BE ACCEPTED' }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  has_many :orders, dependent: :destroy
  has_one :cart, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_one :measurement, dependent: :destroy

  private

  def create_measurement
    Measurement.create(user: self)
  end
end
