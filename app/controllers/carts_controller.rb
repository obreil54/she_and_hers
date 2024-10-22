class CartsController < ApplicationController
  before_action :find_cart

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

    total_price = @cart.total_price.format(symbol: true, no_cents: true)

    respond_to do |format|
      format.json { render json: { total_items: @cart.cart_items.sum(:quantity), total_price: total_price, cart_id: @cart.id } }
    end
  end

  def remove_item
    @cart = Cart.find(params[:cart_id])
    @cart_item = @cart.cart_items.find(params[:item_id])

    if @cart_item&.destroy
      render json: { success: true, total_items: @cart.cart_items.count }
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

  private

  def find_cart
    @cart = current_user ? current_user.cart : Cart.find_or_create_by(id: session[:cart_id])
    session[:cart_id] ||= @cart.id
  end

  def current_cart
    if current_user
      current_user.cart || current_user.create_cart
    else
      Cart.find_or_create_by(id: session[:cart_id]) do |cart|
        session[:cart_id] = cart.id
      end
    end
  end
end
