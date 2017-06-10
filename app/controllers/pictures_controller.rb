class PicturesController < ApplicationController
  require 'rubygems' if RUBY_VERSION < '1.9'
  require 'rest-client'
  require 'base64'
  require 'google/api_client'
  require 'trollop'
  attr_reader :image_remote_url

  def index
    @pictures = Picture.all
  end

  def show
    @album = current_user.album
    @picture = Picture.find(params[:id])

    # Imagga API
    # Converts tags to JSON format
    @response = JSON.parse(@picture.tags)

    # Retrieves tags and confidences
    @tags = @response.fetch("results").first.fetch("tags")[0..4]
    @first = @response.fetch("results").first.fetch("tags").first.fetch("tag")
    @second = @response.fetch("results").first.fetch("tags").second.fetch("tag")
    @confidence = @tags.first['confidence'].ceil

    # Confidence flash messages
    if @confidence >= 75
      flash[:confident] = "We're happy to announce that we're #{@confidence}% sure that the results are accurate!!"
    elsif @confidence >= 50
      flash[:maybe] = "We're only #{@confidence}% sure that this is what you're looking for..."
    else
      flash[:unconfident] = "Sorry, we're only #{@confidence}% confident with our results, so it's probably wrong... Try uploading another image instead?"
    end

    # Youtube API
    # Initialize
    videos = Yt::Collections::Videos.new

    # Orders videos by relevance
    @result = videos.where(order: 'relevance')

    # Sets Youtube search query using top two tags
    @query = @first+' '+@second

    # Passes query as param for Youtube API
    get_service
    @videos = main(@query)

    # Gets random video link from range 1..10
    @rand = rand(0..10)
    @link = @videos[@rand][-12..-2]

    # GIPHY API

    # Gets gif using first and second picture tags
    @giphyResponse = JSON.parse(RestClient.get "http://api.giphy.com/v1/gifs/search?q=#{@first}+#{@second}&api_key=#{ENV['GIPHY_API_KEY_PUBLIC']}")

    # Gets size of results
    @giphyRange = @giphyResponse.fetch("data").size

    # Sets range
    @giphyRand = rand(0..@giphyRange-1)
    if @giphyRange > 10
      @giphyEmbed = @giphyResponse.fetch("data")[rand(0..10)].fetch("embed_url")
    else
      @giphyEmbed = @giphyResponse.fetch("data")[@giphyRand].fetch("embed_url")
    end

    if user_signed_in?
      @album = current_user.album
    end

    puts @response

  end

  def new
    @album = Album.where(user_id: current_user.id)
    # byebug
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

  def destroy
    @picture = Picture.find(params[:id])
    if @picture.destroy
      flash[:notice] = "Image deleted"
      redirect_to album_index_path
    else
      flash[:alert] = "There was an issue deleting image"
      render :show
    end
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
    opts = {:q=>query, :max_results=> 25, :help=>false}

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
    params.require(:picture).permit(:picture_remote_url, :tags)
  end
end
