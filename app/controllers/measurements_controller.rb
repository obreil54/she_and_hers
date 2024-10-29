class MeasurementsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_measurement

  def edit
  end

  def update
    if @measurement.update(measurement_params)
      redirect_to user_path(current_user)
    else
      render :edit
    end
  end

    private

    def set_measurement
      @measurement = current_user.measurement
    end


    def measurement_params
      params.require(:measurement).permit(:chest, :waist, :high_hips, :low_hips, :thigh, :torso, :arm_length, :shoulder_width, :upper_arm_circumference, :inseam, :height)
    end
end
