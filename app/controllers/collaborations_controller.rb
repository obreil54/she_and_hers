class CollaborationsController < ApplicationController
  before_action :authorize_admin, only: [:new, :create, :edit, :update, :destroy]

  def index
    @collaborations = Collaboration.order(position: :asc)
  end
  def new
    @collaboration = Collaboration.new
  end

  def create
    @collaboration = Collaboration.new(collaboration_params)

    if @collaboration.save
      redirect_to collaborations_path, notice: "Collaboration created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @collaboration = Collaboration.find(params[:id])
  end

  def edit
    @collaboration = Collaboration.find(params[:id])
  end

  def update
    @collaboration = Collaboration.find(params[:id])

    if @collaboration.update(collaboration_params.except(:images))
      valid_images = params[:collaboration][:images].reject(&:blank?)

      if valid_images.any?
        @collaboration.images.purge
        valid_images.each do |photo|
          @collaboration.images.attach(photo)
        end
      end

      redirect_to collaboration_path(@collaboration), notice: "Collaboration updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @collaboration = Collaboration.find(params[:id])
    @collaboration.destroy
    redirect_to collaborations_path, notice: "Collaboration deleted successfully."
  end

  private

  def collaboration_params
    params.require(:collaboration).permit(:name, :description, :primary_image, :position, images: [], youtube_links: []).tap do |whitelisted|
      whitelisted[:youtube_links] = params[:collaboration][:youtube_links].to_s.split("\n").map(&:strip)
    end
  end

  def authorize_admin
    redirect_to root_path, alert: "You are not authorized to perform this action." unless current_user&.admin?
  end
end
