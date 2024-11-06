class NewsletterController < ApplicationController
  def subscribe
    email = params[:email]

    if email.present?
      gibbon = Gibbon::Request.new
      list_id = ENV['MAILCHIMP_LIST_ID']
      subscriber_id = Digest::MD5.hexdigest(email.downcase)

      begin
        member = gibbon.lists(list_id).members(subscriber_id).retrieve
        if member.body["status"] == "subscribed"
          flash[:notice] = "You're already subscribed!"
        else
          gibbon.lists(list_id).members(subscriber_id).upsert(
            body: {
              email_address: email,
              status: "subscribed"
            }
          )
          flash[:notice] = "Thank you for subscribing!"
          send_discount_code(email)
        end
      rescue Gibbon::MailChimpError => e
        flash[:alert] = "There was an error: #{e.message}"
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
