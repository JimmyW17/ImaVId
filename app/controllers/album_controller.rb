class AlbumController < ApplicationController
  def index
    @user = current_user
    @pictures = current_user.album.pictures.all
  end

  def edit
    @album = Album.find(current_user.id)
  end

  def update
    @album = Album.find(current_user.id)
    @album.pictures.update
  end

  private

  def picture_params
    params.require(:picture).permit(:image_file_name)
  end
end
