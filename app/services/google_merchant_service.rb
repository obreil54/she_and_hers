class GoogleMerchantService
  Content = Google::Apis::ContentV2_1

  def initialize
    @merchant_id = ENV['GOOGLE_MERCHANT_ID']
    @service = Content::ShoppingContentService.new
    @service.authorization = authorize
  end

  def authorize
    Google::Auth::UserRefreshCredentials.new(
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      scope: ['https://www.googleapis.com/auth/content'],
      refresh_token: ENV['GOOGLE_REFRESH_TOKEN']
    )
  end

  # Check if a product exists in Google Merchant Center
  def find_product(product_id)
    @service.get_product(@merchant_id, product_id.to_s)
  rescue Google::Apis::ClientError => e
    return nil if e.status_code == 404 # Return nil if the product is not found
    raise e # Raise other errors
  end

  def insert_product(product)
    google_product = build_google_product(product)
    @service.insert_product(@merchant_id, google_product)
  end

  def update_product(product)
    google_product = build_google_product(product)
    @service.update_product(@merchant_id, product.id.to_s, google_product)
  end

  private

  def build_google_product(product)
    google_item_id = "online:en:GB:#{product.id}"
    image_urls = [product.secondary_photo.url, product.tertiary_photo.url] + product.other_photos.map(&:url)
    additional_images = image_urls.join(',')
    p "additional_images: #{additional_images}"

    Content::Product.new(
      id: google_item_id,
      title: product.name,
      description: product.description,
      link: Rails.application.routes.url_helpers.product_url(product, host: 'shersstudios.com'),
      image_link: product.primary_photo.url,
      additional_image_link: additional_images,
      content_language: 'en',
      target_country: 'GB',
      price: Content::Price.new(value: product.price.amount.to_s, currency: 'GBP'),
      availability: 'in stock',
      condition: 'new',
      channel: 'online',
      offer_id: "shers_studios-#{product.id}",
      brand: 'Shers Studios',
    )
  end
end
