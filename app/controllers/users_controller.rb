class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(params[:id])
    @addresses = @user.addresses
    @orders = @user.orders.where.not(status: 'pending')
  end
end
