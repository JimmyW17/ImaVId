class PicturesController < ApplicationController
  require 'rubygems' if RUBY_VERSION < '1.9'
  require 'rest-client'
  require 'base64'
  require 'google/api_client'
  require 'trollop'
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
    # api_key = ENV['IMAGGA_API_KEY']
    # api_secret = ENV['IMAGGA_API_SECRET']
    # auth = 'Basic ' + Base64.strict_encode64( "#{api_key}:#{api_secret}" ).chomp
    #
    # @response = JSON.parse((RestClient.get "https://api.imagga.com/v1/tagging?url=#{@picture.picture_remote_url}", { :Authorization => auth }))
    # @first = @response.fetch("results").first.fetch("tags").first.fetch("tag")
    # @firstConfidence = @response.fetch("results").first.fetch("tags").first.fetch("tag")
    # @second = @response.fetch("results").first.fetch("tags").second.fetch("tag")
    # @third = @response.fetch("results").first.fetch("tags").third.fetch("tag")
    # videos = Yt::Collections::Videos.new
    # @result = videos.where(order: 'relevance')
    # @query = @first+' '+@second
    # get_service
    # @videos = main(@query)
    # # byebug
    # @link = @videos[0][-12..-2]
    #
    # # GIPHY API
    # @giphyResponse = JSON.parse(RestClient.get "http://api.giphy.com/v1/gifs/search?q=#{@first}+#{@second}&api_key=#{ENV['GIPHY_API_KEY_PUBLIC']}")
    # @giphyEmbed = @giphyResponse.fetch("data").first.fetch("embed_url")
    #
    # if user_signed_in?
    #   @album = current_user.album
    #   # @picture = Picture.new(:album=>@album)
    # end
    # # byebug
    # # render :index
    #
    # puts @response
    # # byebug
    #
    # # Youtube stuff
    # videos = Yt::Collections::Videos.new
    # @result = videos.where(order: 'relevance')
    #
    # if params[:q]
    #   @query = params[:q]
    #   get_service
    #   @videos = main(@query)
    #   @link = @videos[0][-12..-2]
    #   byebug
    # end
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

  DEVELOPER_KEY = ENV['GOOGLE_API_KEY']
  YOUTUBE_API_SERVICE_NAME = 'youtube'
  YOUTUBE_API_VERSION = 'v3'

  def get_service
    client = Google::APIClient.new(
    :key => DEVELOPER_KEY,
    :authorization => nil,
    :application_name => $PROGRAM_NAME,
    :application_version => '1.0.0'
    )
    youtube = client.discovered_api(YOUTUBE_API_SERVICE_NAME, YOUTUBE_API_VERSION)
    return client, youtube
  end

  def main(query)
    puts "query..........."
    puts @query
    opts = Trollop::options do
      opt :q, 'Search term', :type => String, :default => query
      opt :max_results, 'Max results', :type => :int, :default => 25
    end

    client, youtube = get_service

    begin
      # Call the search.list method to retrieve results matching the specified
      # query term.
      search_response = client.execute!(
      :api_method => youtube.search.list,
      :parameters => {
        :part => 'snippet',
        :q => opts[:q],
        :maxResults => opts[:max_results]
      }
      )

      videos = []
      channels = []
      playlists = []

      # Add each result to the appropriate list, and then display the lists of
      # matching videos, channels, and playlists.
      search_response.data.items.each do |search_result|
        case search_result.id.kind
        when 'youtube#video'
          videos << "#{search_result.snippet.title} (#{search_result.id.videoId})"
        when 'youtube#channel'
          channels << "#{search_result.snippet.title} (#{search_result.id.channelId})"
        when 'youtube#playlist'
          playlists << "#{search_result.snippet.title} (#{search_result.id.playlistId})"
        end
      end

      # puts "Videos:\n", videos, "\n"
      # puts "Channels:\n", channels, "\n"
      # puts "Playlists:\n", playlists, "\n"
    rescue Google::APIClient::TransmissionError => e
      puts e.result.body
    end
    videos
  end

  private

  def picture_params
    params.require(:picture).permit(:image, :picture_remote_url)
  end
end
