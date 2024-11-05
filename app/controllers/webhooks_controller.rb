class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    begin
      endpoint_secret = Rails.env.production? ? ENV['STRIPE_LIVE_WEBHOOK_SECRET'] : ENV['STRIPE_TEST_WEBHOOK_SECRET']
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => e
      render json: { error: 'Invalid payload'}, status: 400 and return
    rescue Stripe::SignatureVerificationError => e
      render json: { error: 'Invalid signature' }, status: 400 and return
    end

    case event.type
    when 'checkout.session.completed'
      session = event.data.object
      order = Order.find_by(checkout_session_id: session.id)
      if order
        order.update(status: 'placed')
      end
    when 'payment_intent.payment_failed'
      session = event.data.object
      order = Order.find_by(checkout_session_id: session.id)
      if order
        order.update(status: 'failed')
      end
    end

    render json: { message: 'Success' }, status: 200
  end

  def shippo
    event = JSON.parse(request.body.read)

    if event['event'] == 'track_updated'
      tracking_status = event['tracking_status']['status']
      tracking_number = event['tracking_number']

      order = Order.find_by(tracking_number: tracking_number)
      if order
        order.update(tracking_status: map_tracking_status(tracking_status))
      end
    end

    render json: { message: 'Received' }, status: 200
  end

  private

  def map_tracking_status(shippo_status)
    case shippo_status
    when 'UNKNOWN'
      'UKNOWN'
    when 'PRE_TRANSIT'
      'PRE TRANSIT'
    when 'TRANSIT'
      'TRANSIT'
    when 'DELIVERED'
      'DELIVERED'
    when 'RETURN_TO_SENDER'
      'RETURN TO SENDER'
    when 'FAILURE'
      'FAILURE'
    when 'AVAILABLE_FOR_PICKUP'
      'AVAILABLE FOR PICKUP'
    when 'OUT_FOR_DELIVERY'
      'OUT FOR DELIVERY'
    else
      'UNKNOWN'
    end
  end
end
