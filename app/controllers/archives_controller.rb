class ArchivesController < ApplicationController
  before_action :authorize_admin, only: [:new, :create, :edit, :update, :destroy]

  def index
    @archives = Archive.order(position: :asc)
  end

  def new
    @archive = Archive.new
  end

  def create
    @archive = Archive.new(archive_params)

    if @archive.save
      redirect_to archives_path, notice: "Archive created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @archive = Archive.find(params[:id])
  end

  def edit
    @archive = Archive.find(params[:id])
  end

  def update
    @archive = Archive.find(params[:id])

    if @archive.update(archive_params.except(:images))
      valid_images = params[:archive][:images].reject(&:blank?)

      if valid_images.any?
        @archive.images.purge
        valid_images.each do |photo|
          @archive.images.attach(photo)
        end
      end

      redirect_to archive_path(@archive), notice: "Archive updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @archive = Archive.find(params[:id])
    @archive.destroy
    redirect_to archives_path, notice: "Archive deleted successfully."
  end

  private

  def archive_params
    params.require(:archive).permit(
      :name,
      :description,
      :primary_image,
      :position,
      images: []
    )
  end

  def authorize_admin
    redirect_to root_path, alert: "You are not authorized to perform this action." unless current_user&.admin?
  end
end
