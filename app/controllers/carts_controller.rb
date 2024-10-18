class CartsController < ApplicationController
  before_action :find_cart

  def add_item
    product = Product.find(params[:product_id])
    size = params[:size]
    cart_item = @cart.cart_items.find_by(product_id: product.id, size: size)

    if cart_item
      cart_item.update(quantity: cart_item.quantity + 1)
    else
      @cart.cart_items.create(product: product, quantity: 1, size: size)
    end

    respond_to do |format|
      format.json { render json: { total_items: @cart.cart_items.sum(:quantity) } }
    end
  end

  def remove_item
    cart_item = @cart.cart_items.find_by(product_id: params[:product_id])

    if cart_item
      cart_item.destroy
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
  end

  private

  def find_cart
    @cart = current_user ? current_user.cart : Cart.find_or_create_by(id: session[:cart_id])
    session[:cart_id] ||= @cart.id
  end
end
