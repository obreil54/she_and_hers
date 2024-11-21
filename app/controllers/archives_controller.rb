class ArchivesController < ApplicationController
  def index
    @archives = Archive.all
  end

  def new
    @archive = Archive.new
  end

  def create
    @archive = Archive.new(archive_params)

    if @archive.save
      redirect_to archive_path(@archive), notice: "Archive created successfully."
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

    if @archive.update(archive_params.except(:other_photos))
      if params[:archive][:other_photos].present?
        params[:archive][:other_photos].each do |photo|
          @archive.other_photos.attach(photo)
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
      images: []
    )
  end
end
