class AccessController < ApplicationController
  skip_before_action :check_access_code

  def show
  end

  def verify
    if params[:access_code] == "YOUR_SECRET_CODE"
      session[:access_granted] = true
      redirect_to root_path
    else
      flash[:alert] = "Invalid access code."
      redirect_to access_code_path
    end
  end
end
