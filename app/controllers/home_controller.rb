class HomeController < ApplicationController
  def index
    @haspictures = false;
    if user_signed_in?
      if current_user.album.pictures && current_user.album.pictures.size > 0
        @album = current_user.album
        @pictures = @album.pictures
        @picture = @pictures[rand(0..@pictures.size-1)]
        @rand_img = @picture.picture_remote_url
        @haspictures = true;
      end
    end
  end
end
