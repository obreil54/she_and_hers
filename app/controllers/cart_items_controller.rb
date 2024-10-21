class CartItemsController < ApplicationController
  def update
    @cart_item = CartItem.find(params[:id])
    if @cart_item.update(quantity: params[:quantity])
      total_items = @cart_item.cart.cart_items.sum(:quantity)
      total_price = @cart_item.cart.total_price.format(symbol: true, no_cents: true)

      render json: { success: true, new_quantity: @cart_item.quantity, total_items: total_items, total_price: total_price }
    else
      render json: { success: false }, status: :unprocessable_entity
    end
  end
end
