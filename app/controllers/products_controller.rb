class ProductsController < ApplicationController
  before_action :authorize_admin, only: [:new, :create, :edit, :update, :destroy]

  def index
    set_meta_tags(
      title: "Slow Fluid Sustainable Fashion | HandMade in UK",
      description: "Shop designer latex dresses, skirts and tops. Limited edition clothing, ethically sourced and produced. Order your next favourite statement dress now!",
      og: {
        title: "Shers Studios | Slow Fluid Sustainable Fashion | HandMade in UK",
        description: "Shop designer latex dresses, skirts and tops. Limited edition clothing, ethically sourced and produced. Order your next favourite statement dress now!"
      },
      twitter: {
        title: "Shers Studios | Slow Fluid Sustainable Fashion | HandMade in UK",
        description: "Shop designer latex dresses, skirts and tops. Limited edition clothing, ethically sourced and produced. Order your next favourite statement dress now!"
      }
    )
    @products = Product.order(updated_at: :desc)
  end

  def show
    @product = Product.find(params[:id])
    first_sentence = @product.description.split('.').first
    set_meta_tags(
      title: "#{@product.name} - #{first_sentence.strip}",
      description: @product.description,
      image: @product.primary_photo.url,
      og: {
        title: "Shers Studios | #{@product.name} - #{first_sentence.strip}",
        description: @product.description,
        image: @product.primary_photo.url
      },
      twitter: {
        title: "Shers Studios | #{@product.name} - #{first_sentence.strip}",
        description: @product.description,
        image: @product.primary_photo.url
      }
    )
    @image_urls = [@product.primary_photo, @product.secondary_photo, @product.tertiary_photo]
    .compact.map(&:url) + @product.other_photos.map(&:url)
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to shop_path, notice: "Product created successfully."
    else
      render :new
    end
  end
  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])

    if @product.update(product_params.except(:other_photos))
      if params[:product][:other_photos].present?
        params[:product][:other_photos].each do |photo|
          @product.other_photos.attach(photo)
        end
      end

      redirect_to product_path(@product), notice: "Product updated successfully."
    else
      render :edit
    end
  end



  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to shop_path, notice: "Product deleted successfully."
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
      :one_size,
      other_photos: []
    )
  end

  def authorize_admin
    redirect_to root_path, alert: "You are not authorized to perform this action." unless current_user&.admin?
  end
end
