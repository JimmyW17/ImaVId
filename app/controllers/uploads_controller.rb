class UploadsController < ApplicationController
  require 'rubygems' if RUBY_VERSION < '1.9'
  require 'rest-client'
  require 'base64'
  require 'google/api_client'
  require 'trollop'

  def index

    # Imagga API
    api_key = ENV['IMAGGA_API_KEY']
    api_secret = ENV['IMAGGA_API_SECRET']
    auth = 'Basic ' + Base64.strict_encode64( "#{api_key}:#{api_secret}" ).chomp
    if params[:image_url]
      # Calls Imagga API with image as param
      @json = RestClient.get "https://api.imagga.com/v1/tagging?url=#{params[:image_url]}", { :Authorization => auth }
      # Records API response
      @response = JSON.parse(@json)
      # Records tags
      @tags = @response.fetch("results").first.fetch("tags")[0..4]
      # Gets confidence and sets flash message
      @confidence = @tags.first['confidence'].ceil
      if @confidence >= 75
        flash[:confident] = "We're happy to announce that we're #{@confidence}% sure that the results are accurate!!"
      elsif @confidence >= 50
        flash[:maybe] = "We're only #{@confidence}% sure that this is what you're looking for..."
      else
        flash[:unconfident] = "Sorry, we're only #{@confidence}% confident with our results, so it's probably wrong... Try uploading another image instead?"
      end
      # Gets top tags
      @first = @response.fetch("results").first.fetch("tags").first.fetch("tag")
      if @response.fetch("results").first.fetch("tags").second
        @second = @response.fetch("results").first.fetch("tags").second.fetch("tag")
      end

      # Youtube API
      videos = Yt::Collections::Videos.new
      # Order by relevance
      @result = videos.where(order: 'relevance')
      # Sets query 1
      @query = @first
      # Sets query 2 if it exists
      if @second
        @query+= ' '+@second
      end
      # Calls Youtube API methods with query as params
      get_service
      @videos = main(@query)
      # Videos range
      @rand = rand(0..10)
      # Video link 1
      @link = @videos[@rand][-12..-2]

      # GIPHY API
      @giphyResponse = JSON.parse(RestClient.get "http://api.giphy.com/v1/gifs/search?q=#{@first}+#{@second}&api_key=#{ENV['GIPHY_API_KEY_PUBLIC']}")
      # Gets number of gifs from result
      @giphyRange = @giphyResponse.fetch("data").size
      # Gets random gif from range
      @giphyRand = rand(0..@giphyRange-1)
      if @giphyRange > 10
        @giphyEmbed = @giphyResponse.fetch("data")[rand(0..10)].fetch("embed_url")
      else
        @giphyEmbed = @giphyResponse.fetch("data")[@giphyRand].fetch("embed_url")
      end
      if user_signed_in?
        @album = current_user.album
        puts current_user
        puts @album
        puts @album.id
        @picture = Picture.new(:album=>@album)
      end
      render :index
    end
  end

  def create
    @picture = Picture.create(picture_params)
    if @picture.save
      render :index
    else
      redirect_to root_path
    end
  end

  # Youtube API Methods
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
    puts query
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
    params.require(:picture).permit(:image)
  end
end
