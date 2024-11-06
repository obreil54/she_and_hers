class NewsletterMailer < ApplicationMailer
  default from: 'no-reply@shersstudios.com'

  def thank_you_email(email, discount_code)
    @discount_code = discount_code
    mail(to: email, subject: 'Thank you for signing up! Enjoy 10% off your next purchase.')
    Rails.logger.info "Mailer 'from' domain: #{mail.from.first.split('@').last}"
    Rails.logger.info "Mailing to: #{@user.email}"
  end
end
