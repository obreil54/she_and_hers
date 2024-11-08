# app/controllers/discount_codes_controller.rb
class DiscountCodesController < ApplicationController
  def validate
    discount_code = DiscountCode.find_by(code: params[:code])

    if discount_code && !discount_code.used
      render json: { valid: true, discount_percentage: discount_code.discount_percentage }
    else
      render json: { valid: false, message: "INVALID OR USED DISCOUNT CODES" }, status: :not_found
    end
  end
end
