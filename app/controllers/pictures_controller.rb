class PicturesController < ApplicationController
  attr_reader :image_remote_url

  def image_remote_url=(url_value)
    self.image = URI.parse(url_value)
    @image_remote_url = url_value
  end

  def index
    @pictures = Picture.all
  end

  def show
    @picture = Picture.find(params[:id])
  end

  def new
    @album = Album.where(user_id: current_user.id)
    @picture = @album.pictures.new
  end

  def create
    @user = current_user
    @album = @user.album
    @picture = @album.pictures.new(picture_params)
    # picture_from_url(params[:image_url])
    # @picture.save!
    if @picture.save
      flash[:notice] = "Image saved"
      redirect_to album_index_path
    else
      flash[:alert] = "Something went wrong attempting to save image"
      redirect_to uploads_path
    end
  end

  def update
    @picture = Picture.find(params[:id])
    @picture.update(picture_params)
    if @picture.save
      flash[:notice] = "Picture updated successfully"
      redirect_to root_path
    else
      flash[:alert] = "Picture update unsuccesful"
      redirect_to uploads_path
    end
  end

  def edit
    @picture = Picture.find(params[:id])
  end

  private

  def picture_params
    params.require(:picture).permit(:image, :picture_remote_url)
  end
end
