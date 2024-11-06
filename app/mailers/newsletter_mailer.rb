class NewsletterMailer < ApplicationMailer
  default from: 'no-reply@shersstudios.com'

  def thank_you_email(email, discount_code)
    @discount_code = discount_code
    mail(to: email, subject: 'Thank you for signing up! Enjoy 10% off your next purchase.')
    Rails.logger.info "Mailchimp Transactional SMTP Response: #{ActionMailer::Base.smtp_settings[:address]}"
    Rails.logger.error "Email error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end
end
