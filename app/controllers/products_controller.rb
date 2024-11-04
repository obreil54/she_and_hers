class ProductsController < ApplicationController
  before_action :authenticate_user!, only: [:index]
  before_action :authorize_admin, only: [:new, :create, :edit, :update, :destroy]

  def index
    @products = Product.all
  end

  def show
    @product = Product.find(params[:id])
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to products_path, notice: "Product created successfully."
    else
      render :new
    end
  end
  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      redirect_to product_path(@product), notice: "Product updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to products_path, notice: "Product deleted successfully."
  end

  private

  def product_params
    params.require(:product).permit(
      :name,
      :price,
      :description,
      :care_instructions,
      :primary_photo,
      :secondary_photo,
      :tertiary_photo,
      :weight,
      other_photos: []
    )
  end

  def authorize_admin
    redirect_to root_path, alert: "You are not authorized to perform this action." unless current_user&.admin?
  end
end
