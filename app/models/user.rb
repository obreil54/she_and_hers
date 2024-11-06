class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  after_create :create_measurement
  after_create :create_wishlist
  after_commit :send_welcome_email, on: :create
  after_commit :subscribe_to_newsletter, on: :create, if: :newsletter?

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

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_later
  end

  def subscribe_to_newsletter
    gibbon = Gibbon::Request.new
    list_id = ENV['MAILCHIMP_LIST_ID']

    begin
      gibbon.lists(list_id).members.create(
        body: {
          email_address: email,
          status: "subscribed"
        }
      )
      Rails.logger.info "User has been subscribed to the newsletter."

      discount_code = DiscountCode.generate_unique_code(10)
      NewsletterMailer.thank_you_email(email, discount_code).deliver_later
    rescue Gibbon::MailChimpError => e
      Rails.logger.error "Mailchimp Error: #{e.message}"
    end
  end
end
