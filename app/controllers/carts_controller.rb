class CartsController < ApplicationController
  def show
    @cart = current_cart
    @guest_checkout = current_user.nil?
    @order = Order.new
  end

  def cart_items_modal
    @cart = current_cart
    render partial: 'carts/cart_items_modal'
  end

  def add_item
    product = Product.find(params[:product_id])
    size = params[:size]
    cart_item = @cart.cart_items.find_by(product_id: product.id, size: size)

    if cart_item
      cart_item.update(quantity: cart_item.quantity + 1)
    else
      @cart.cart_items.create(product: product, quantity: 1, size: size)
    end

    total_price = @cart.total_price.format(symbol: true, no_cents: false)

    respond_to do |format|
      format.json { render json: { total_items: @cart.cart_items.sum(:quantity), total_price: total_price, cart_id: @cart.id } }
    end
  end

  def remove_item
    @cart_item = @cart.cart_items.find_by(id: params[:item_id])

    if @cart_item&.destroy
      total_price = @cart.total_price.format(symbol: true, no_cents: false)
      total_items = @cart.cart_items.sum(:quantity)

      render json: { success: true, total_items: total_items, total_price: total_price }
    else
      render json: { success: false }, status: :unprocessable_entity
    end
  end

  def update_item_quantity
    cart_item = @cart.cart_items.find_by(product_id: params[:product_id])

    if cart_item
      new_quantity = params[:quantity].to_i
      if new_quantity > 0
        cart_item.update(quantity: new_quantity)
      else
        cart_item.destroy
      end
    end

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("cart-items-container", partial: "carts/cart_items_modal", locals: { cart: @cart }) }
      format.json { render json: { success: true } }
    end
  end
end
