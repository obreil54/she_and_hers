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
    begin
      # Initialize Brevo API client
      api_instance = Brevo::ContactsApi.new
      api_instance.api_client.config.api_key['api-key'] = ENV['BREVO_API_KEY']

      # Define the list ID and contact details
      list_id = ENV['BREVO_LIST_ID'] # Replace with your Brevo list ID
      contact = {
        email: email,
        listIds: [list_id.to_i] # List ID must be an integer
      }

      # Add the contact to Brevo list
      api_instance.create_contact(contact)
      Rails.logger.info "User has been subscribed to the newsletter."

      # Generate a discount code and send thank-you email
      discount_code = DiscountCode.generate_unique_code(10)
      NewsletterMailer.thank_you_email(email, discount_code).deliver_later

    rescue Brevo::ApiError => e
      Rails.logger.error "Brevo API Error: #{e.message}"
    end
  end

end
