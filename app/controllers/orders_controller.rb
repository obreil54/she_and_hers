class OrdersController < ApplicationController
  require 'stripe'
  require 'shippo'

  def create
    p "Order params: #{order_params}"
    @cart = current_cart
    @order = Order.new(order_params)


    @cart.cart_items.each do |item|
      @order.order_items.build(product: item.product, quantity: item.quantity, size: item.size)
    end
    p "Order Items after mapping: #{@order.order_items.inspect}"

    if current_user
      @order.user = current_user
      @order.email = current_user.email
      @order.first_name = current_user.first_name
      @order.last_name = current_user.last_name
      @order.phone = current_user.phone if current_user.phone.present?

      if params[:order][:address_id].present?
        existing_address = current_user.addresses.find(params[:order][:address_id])
        assign_address(@order, existing_address)
      else
        assign_address(@order, params[:order])
      end
    else
      @order.email = params[:order][:email]
      @order.first_name = params[:order][:first_name]
      @order.last_name = params[:order][:last_name]
      @order.phone = params[:order][:phone]
      assign_address(@order, params[:order])
    end

    @order.shipping_cost_cents = (params[:order][:shipping_cost].to_f * 100).to_i if params[:order][:shipping_cost].present?
    total_amount_cents = @cart.total_price.cents + (@order.shipping_cost_cents || 0)
    @order.total_amount_cents = total_amount_cents
    @order.status = 'pending'

    if @order.save
      begin
        shipment = Shippo::Shipment.create(
          address_from: {
            name: "Polina Oleynikova",
            street1: "Hamilton House Queens Drive",
            street2: "Queens Drive",
            city: "Leatherhead",
            state: "Surrey",
            zip: "KT22 0PF",
            country: "United Kingdom",
            phone: "07818130656"
          },
          address_to: {
            name: "#{@order.first_name} #{@order.last_name}",
            street1: @order.address_line1,
            street2: @order.address_line2,
            city: @order.city,
            state: @order.state,
            zip: @order.postal_code,
            country: @order.country,
            phone: @order.phone
          },
          parcels: [{
            length: "10",
            width: "7",
            height: "4",
            distance_unit: "in",
            weight: "2",
            mass_unit: "lb"
          }],
          async: false
        )

        selected_provider = params[:order][:selected_provider]
        selected_service_level = params[:order][:selected_service_level]
        selected_amount = params[:order][:shipping_cost]
        rate = shipment['rates'].find do |r|
          r['provider'].to_s == selected_provider.to_s &&
          r.dig('servicelevel', 'name').to_s == selected_service_level.to_s &&
          r['amount'].to_s == selected_amount.to_s
        end
        p "Selected rate: #{rate.inspect}"

        if rate
          label = Shippo::Transaction.create(
            rate: rate['object_id'],
            async: false
            )

          p "Label response: #{label.inspect}"

          if label.present? && label['tracking_number'].present?
            p "Shipping label created: #{label.inspect}"
            tracking_number = label['tracking_number']
            p "Tracking number: #{tracking_number}"
            @order.update(tracking_number: tracking_number, tracking_status: 'pre_transit')
          else
            p "Unable to generate shipping label or tracking number."
          end
        else
          p "Selected rate not found in shipment rates."
        end
      rescue Shippo::Exceptions::APIError => e
        logger.error "Shippo API Error: #{e.message}"
      rescue Shippo::Exceptions::APIServerError => e
        logger.error "Shippo API Server Error: #{e.message}"
      rescue => e
        logger.error "General Error while creating shipment: #{e.message}"
      end

      session = Stripe::Checkout::Session.create(
        payment_method_types: ['card'],
        line_items: @order.order_items.map { |item|
          {
            price_data: {
              currency: 'gbp',
              product_data: {
                name: item.product.name,
                images: [item.product.primary_photo.url],
              },
              unit_amount: item.product.price_cents,
            },
            quantity: item.quantity,
          }
        } + [
          {
            price_data: {
              currency: 'gbp',
              product_data: {
                name: 'Shipping',
              },
              unit_amount: @order.shipping_cost_cents,
            },
            quantity: 1,
          }
        ],
        mode: 'payment',
        success_url: success_order_url(@order),
        customer_email: @order.email,
        metadata: {
          order_id: @order.id,
        },
      )

      p "Session: #{session.inspect}"
      p "Session ID: #{session.id}"
      @order.update(checkout_session_id: session.id)

      respond_to do |format|
        format.json { render json: { id: session.id } }
      end
    else
      p @order.errors.full_messages # Add this line to see any validation issues
      render json: { error: "Error creating order: #{@order.errors.full_messages.join(', ')}" }, status: :unprocessable_entity
    end
  end

  def success
    @order = Order.find(params[:id])
    if @order
      session = Stripe::Checkout::Session.retrieve(@order.checkout_session_id)

      if session.payment_intent
        payment_intent = Stripe::PaymentIntent.retrieve(session.payment_intent)

        if payment_intent.latest_charge
          charge = Stripe::Charge.retrieve(payment_intent.latest_charge)
          receipt_url = charge.receipt_url
          @order.update(receipt_url: receipt_url) if receipt_url.present?
        end
      end

      cart = current_cart
      if cart
        cart.cart_items.destroy_all
      end
    end

    if current_user && !current_user.addresses.exists?(address_line1: @order.address_line1, postal_code: @order.postal_code)
      current_user.addresses.create(
        address_line1: @order.address_line1,
        address_line2: @order.address_line2,
        city: @order.city,
        state: @order.state,
        postal_code: @order.postal_code,
        country: @order.country,
      )
    end
  end

  private

  def order_params
    params.require(:order).except(:authenticity_token, :address_id).permit(:email, :first_name, :last_name, :total_amount_cents, :address_line1, :address_line2, :city, :state, :postal_code, :country, :phone, :shipping_cost)
  end

  def assign_address(order, source)
    order.address_line1 = source[:address_line1]
    order.address_line2 = source[:address_line2]
    order.city = source[:city]
    order.state = source[:state]
    order.postal_code = source[:postal_code]
    order.country = source[:country]
  end
end