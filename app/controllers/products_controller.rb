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
      sync_with_google_merchant(@product)
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

      sync_with_google_merchant(@product)
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


  def sync_with_google_merchant(product)
    service = GoogleMerchantService.new

    begin
      # Check if the product exists in Google Merchant using the product's ID
      google_product = service.find_product("online:en:GB:#{product.id}")

      # If the product exists, update it. If not, insert a new product.
      if google_product
        service.update_product(product)
        Rails.logger.info "Updated product #{product.name} in Google Merchant."
      else
        service.insert_product(product)
        Rails.logger.info "Added product #{product.name} to Google Merchant."
      end
    rescue Google::Apis::Error => e
      Rails.logger.error "Failed to sync product #{product.name} with Google Merchant: #{e.message}"
    end
  end

end
