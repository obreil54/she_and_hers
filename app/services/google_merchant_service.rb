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

  def find_product(product_id)
    @service.get_product(@merchant_id, product_id.to_s)
  rescue Google::Apis::ClientError => e
    return nil if e.status_code == 404
    raise e
  end

  def insert_product(product)
    p "Inserting product: #{product.inspect}"
    google_products = build_google_product(product)
    google_products.each do |google_product|
      @service.insert_product(@merchant_id, google_product)
    end
  end

  def update_product(product)
    p "Updating product: #{product.inspect}"
    google_products = build_google_product(product)
    google_products.each do |google_product|
      @service.update_product(@merchant_id, product.id.to_s, google_product)
    end
  end

  def build_google_product(product)
    p "Local Product: #{product.inspect}"

    google_item_id = "online:en:GB:#{product.id}"
    image_urls = [product.secondary_photo.url, product.tertiary_photo.url] + product.other_photos.map(&:url)
    sizes = ["2XS", "XS", "S", "M", "L", "XL", "2XL"]

    if product.one_size
      google_product = Content::Product.new(
        id: google_item_id,
        title: product.name,
        description: product.description,
        link: Rails.application.routes.url_helpers.product_url(product, host: 'shersstudios.com'),
        image_link: product.primary_photo.url,
        additional_image_links: image_urls,
        content_language: 'en',
        target_country: 'GB',
        price: Content::Price.new(value: product.price.amount.to_s, currency: 'GBP'),
        availability: 'in stock',
        condition: 'new',
        channel: 'online',
        offer_id: "shers_studios-#{product.id}",
        brand: 'Shers Studios',
        age_group: 'adult',
        gender: 'female',
        sizes: ['one size'],
        color: product.color.name
      )
      p "google_product: #{google_product.inspect}"
      return [google_product]

    else
      google_products = sizes.map do |size|
        Content::Product.new(
          item_group_id: google_item_id,
          id: "#{google_item_id} - #{size}",
          title: "#{product.name} - #{size}",
          description: product.description,
          link: Rails.application.routes.url_helpers.product_url(product, host: 'shersstudios.com'),
          image_link: product.primary_photo.url,
          additional_image_links: image_urls,
          content_language: 'en',
          target_country: 'GB',
          price: Content::Price.new(value: product.price.amount.to_s, currency: 'GBP'),
          availability: 'in stock',
          condition: 'new',
          channel: 'online',
          offer_id: "shers_studios-#{product.id}:#{size}",
          brand: 'Shers Studios',
          age_group: 'adult',
          gender: 'female',
          sizes: [size],
          color: product.color.name
        )
      end
      return google_products
    end
  end
end
