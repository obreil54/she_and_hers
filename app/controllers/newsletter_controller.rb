class NewsletterController < ApplicationController
  def subscribe
    email = params[:email]

    if email.present?
      list_id = ENV['BREVO_LIST_ID']

      begin
        # Initialize Brevo API client
        api_instance = Brevo::ContactsApi.new
        api_instance.api_client.config.api_key['api-key'] = ENV['BREVO_API_KEY']

        # Add contact to Brevo list
        api_instance.create_contact({
          email: email,
          listIds: [list_id.to_i]
        })

        flash[:notice] = "Thank you for subscribing!"
        send_discount_code(email)

      rescue Brevo::ApiError => e
        Rails.logger.error "Brevo API Error: #{e.message}"
        flash[:alert] = "There was an error. If you already subscribed, you will not be able to again."
      end
    else
      flash[:alert] = "Email address cannot be blank."
    end

    redirect_to root_path
  end

  private

  def send_discount_code(email)
    discount_code = DiscountCode.generate_unique_code(10)
    NewsletterMailer.thank_you_email(email, discount_code).deliver_later
  end
end
