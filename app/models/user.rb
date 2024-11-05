class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  after_create :create_measurement
  after_create :create_wishlist

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :terms_of_service, acceptance: { message: 'MUST BE ACCEPTED' }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  has_many :orders, dependent: :destroy
  has_one :cart, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_one :measurement, dependent: :destroy
  has_one :wishlist, dependent: :destroy
  validates :phone, format: { with: /\A[+\d\s()-]{7,}\z/, message: "must be a valid phone number" }

  def has_measurements?
    measurement && measurement.attributes.except("id", "user_id", "created_at", "updated_at").values.all?(&:present?)
  end

  private

  def create_measurement
    Measurement.create(user: self)
  end

  def create_wishlist
    Wishlist.create(user: self)
  end

end
