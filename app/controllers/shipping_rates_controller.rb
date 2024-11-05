class ShippingRatesController < ApplicationController
  require 'shippo'

  SMALL_BOX = { length: 30, width: 22, height: 5, weight: 100, max_products: 2, max_weight: 320 }
  LARGE_BOX = { length: 44.9, width: 33.7, height: 7.9, weight: 150, max_weight: 1300 }
  def create
    address_to = build_address_to(params)

    logger.debug "Address to be used for shipment: #{address_to.inspect}"

    begin
      parcel = select_parcel(current_cart.cart_items)

      shipment = Shippo::Shipment.create(
        address_from: {
          name: "Polina Oleynikova",
          street1: "Hamilton House Queens Drive",
          street2: "Queens Drive",
          city: "Leatherhead",
          state: "Surrey",
          zip: "KT22 0PF",
          country: "United Kingdom",
          phone: "07818130656"
        },
        address_to: address_to,
        parcels: [parcel],
        async: false
      )

      logger.debug "Shippo Shipment Response: #{shipment.inspect}"

      rates = shipment['rates'].select do |rate|
        rate['amount'].present? && rate['currency'] == 'GBP'
      end

      if rates.any?
        formatted_rates = rates.map do |rate|
          {
            provider: rate['provider'],
            amount: rate['amount'],
            currency: rate['currency'],
            service_level: rate['servicelevel']['name'],
          }
        end

        render json: formatted_rates
      else
        logger.error "No valid rates found: #{shipment['messages']}"
        render json: { error: "No valid shipping rates found for the provided address" }, status: :unprocessable_entity
      end
    rescue Shippo::Exceptions::APIError => e
      logger.error "Shippo API Error: #{e.message}"
      render json: { error: "Error communicating with Shippo: #{e.message}" }, status: :internal_server_error
    rescue Shippo::Exceptions::APIServerError => e
      logger.error "Shippo API Server Error: #{e.message}"
      render json: { error: "Shippo server error: please try again later" }, status: :internal_server_error
    rescue => e
      logger.error "General Error: #{e.message}"
      render json: { error: "An unexpected error occurred: #{e.message}" }, status: :internal_server_error
    end
  end

  private

  def select_parcel(cart_items)
    total_product_weight = cart_items.sum { |item| item.product.weight * item.quantity }
    box = SMALL_BOX

    if cart_items.size <= SMALL_BOX[:max_products] && (total_product_weight + SMALL_BOX[:weight] <= SMALL_BOX[:max_weight])
      p "Using small box"
      total_weight = total_product_weight + SMALL_BOX[:weight]
      box = SMALL_BOX
    else
      p "Using large box"
      total_weight = total_product_weight + LARGE_BOX[:weight]
      box = LARGE_BOX
    end

    {
      length: box[:length],
      width: box[:width],
      height: box[:height],
      distance_unit: "cm",
      weight: total_weight.to_s,
      mass_unit: "g"
    }
  end

  def build_address_to(params)
    p "Params: #{params.inspect}"
    order_params = extract_order_params(params)
    p "Order Params: #{order_params.inspect}"

    if current_user
      if order_params["address_id"].present?
        p "Going to use existing address: #{order_params["address_id"]}"
        existing_address = current_user.addresses.find(order_params["address_id"])
        p existing_address.inspect
        {
          name: "#{current_user.first_name} #{current_user.last_name}",
          street1: existing_address.address_line1 || raise_missing_field_error('address_line1'),
          street2: existing_address.address_line2,
          city: existing_address.city || raise_missing_field_error('city'),
          state: existing_address.state,
          zip: existing_address.postal_code || raise_missing_field_error('postal_code'),
          country: existing_address.country || raise_missing_field_error('country'),
          phone: current_user.phone
        }
      else
        p "Going to use new address"
        {
          name: "#{current_user.first_name} #{current_user.last_name}",
          street1: order_params["address_line1"] || raise_missing_field_error('address_line1'),
          street2: order_params["address_line2"],
          city: order_params["city"] || raise_missing_field_error('city'),
          state: order_params["state"],
          zip: order_params["postal_code"] || raise_missing_field_error('postal_code'),
          country: order_params["country"] || raise_missing_field_error('country'),
          phone: current_user.phone
        }
      end
    else
      p "Going to use guest address"
      {
        name: "#{order_params["first_name"]} #{order_params["last_name"]}",
        street1: order_params["address_line1"] || raise_missing_field_error('address_line1'),
        street2: order_params["address_line2"],
        city: order_params["city"] || raise_missing_field_error('city'),
        state: order_params["state"],
        zip: order_params["postal_code"] || raise_missing_field_error('postal_code'),
        country: order_params["country"] || raise_missing_field_error('country'),
        phone: order_params["phone"]
      }
    end
  end

  def raise_missing_field_error(field_name)
    raise "Missing required address field: #{field_name}"
  end

  def extract_order_params(params)
    {
      "address_id" => params["order[address_id]"],
      "address_line1" => params["order[address_line1]"],
      "address_line2" => params["order[address_line2]"],
      "city" => params["order[city]"],
      "state" => params["order[state]"],
      "postal_code" => params["order[postal_code]"],
      "country" => params["order[country]"],
      "first_name" => params["order[first_name]"],
      "last_name" => params["order[last_name]"],
      "phone" => params["order[phone]"]
    }
  end
end
