class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_cart
  helper_method :current_cart

  def current_cart
    if current_user
      current_user.cart || current_user.create_cart
    else
      Cart.find_by(id: session[:cart_id]) || Cart.create.tap { |cart| session[:cart_id] = cart.id }
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :phone, :admin, :address_line1, :address_line2, :city, :state, :postal_code, :country, :terms_of_service])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone, :admin, :address_line1, :address_line2, :city, :state, :postal_code, :country])
  end

  def set_cart
    @cart = current_user ? current_user.cart || current_user.create_cart : Cart.find_by(id: session[:cart_id]) || Cart.create
    session[:cart_id] = @cart.id unless current_user
  end
end
