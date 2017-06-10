class HomeController < ApplicationController
  def index
    @haspictures = false;

    # Checks if signed in and has any pictures in their album
    if user_signed_in? && Picture.all.size > 0
      if current_user.album.pictures && current_user.album.pictures.size > 0
        @album = current_user.album
        @pictures = @album.pictures

        # Gets random picture from album and displays it
        @picture = @pictures[rand(0..@pictures.size-1)]
        @rand_img = @picture.picture_remote_url
        @haspictures = true;
      end
    end
  end
end
