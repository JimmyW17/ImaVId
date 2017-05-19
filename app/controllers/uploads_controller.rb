class UploadsController < ApplicationController
  require 'rubygems' if RUBY_VERSION < '1.9'
  require 'rest-client'
  require 'base64'
  require 'google/api_client'
  require 'trollop'

  # api_key = ENV['IMAGGA_API_KEY']
  # api_secret = ENV['IMAGGA_API_SECRET']

  # @auth = 'Basic ' + Base64.strict_encode64( "#{api_key}:#{api_secret}" ).chomp
  # response = RestClient.get "https://api.imagga.com/v1/tagging?url=#{:image_url}", { :Authorization => auth }
  attr_accessor :query, :opts


  def index
    api_key = ENV['IMAGGA_API_KEY']
    api_secret = ENV['IMAGGA_API_SECRET']
    auth = 'Basic ' + Base64.strict_encode64( "#{api_key}:#{api_secret}" ).chomp
    if params[:image_url]
      response = RestClient.get "https://api.imagga.com/v1/tagging?url=#{params[:image_url]}", { :Authorization => auth }
    end
    puts response
    # byebug

    # Youtube stuff
    videos = Yt::Collections::Videos.new
    @result = videos.where(order: 'viewCount')

    if params[:q]
      @query = params[:q]
      get_service
      main(@query)
      byebug
    end
  end




  # Set DEVELOPER_KEY to the API key value from the APIs & auth > Credentials
  # tab of
  # {{ Google Cloud Console }} <{{ https://cloud.google.com/console }}>
  # Please ensure that you have enabled the YouTube Data API for your project.

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
      puts '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
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

      puts "Videos:\n", videos, "\n"
      puts "Channels:\n", channels, "\n"
      puts "Playlists:\n", playlists, "\n"
    rescue Google::APIClient::TransmissionError => e
      puts e.result.body
    end
  end
end
