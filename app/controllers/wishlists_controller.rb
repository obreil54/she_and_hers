class WishlistsController < ApplicationController
  before_action :authenticate_user!

  def toggle
    product = Product.find(params[:product_id])
    wishlist = current_user.wishlist

    if wishlist.products.include?(product)
      wishlist.products.delete(product)
      @added = false
    else
      wishlist.products << product
      @added = true
    end

    respond_to do |format|
      format.json { render json: { added: @added } }
    end
  end
end
