class CollaborationsController < ApplicationController
  def index
    @collaborationss = Collaboration.all
  end
  def new
    @collaboration = Collaboration.new
  end

  def create
    @collaboration = Collaboration.new(collaboration_params)

    if @collaboration.save
      redirect_to collaboration_path(@collaboration), notice: "Collaboration created successfully."
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

    if @collaboration.update(collaboration_params.except(:other_photos))
      if params[:collaboration][:other_photos].present?
        params[:collaboration][:other_photos].each do |photo|
          @collaboration.other_photos.attach(photo)
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
    params.require(:collaboration).permit(
      :name,
      :description,
      :primary_image,
      images: []
    )
  end
end
