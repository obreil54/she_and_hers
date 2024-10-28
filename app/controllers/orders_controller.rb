class OrdersController < ApplicationController
  require 'stripe'

  def create
    p "Order params: #{order_params}"
    @cart = current_cart
    @order = Order.new(order_params)
    @order.order_items = @cart.cart_items.map { |item| OrderItem.new(product: item.product, quantity: item.quantity, size: item.size) }

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

    @order.total_amount_cents = @cart.total_price.cents
    @order.status = 'pending'

    if @order.save
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
        },
        mode: 'payment',
        success_url: success_order_url(@order),
        customer_email: @order.email,
        metadata: {
          order_id: @order.id,
        },
      )

      @order.update(checkout_session_id: session.id)

      respond_to do |format|
        format.json { render json: { id: session.id } }
      end
    else
      render :new, alert: "Error creating order"
    end
  end

  def success
    @order = Order.find(params[:id])
    if @order
      @order.update(status: 'placed')

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
    params.require(:order).permit(:email, :first_name, :last_name, :total_amount_cents, :address_line1, :address_line2, :city, :state, :postal_code, :country, :phone)
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
