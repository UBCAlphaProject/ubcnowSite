class BlipsController < ApplicationController
  def new
    @blip = Blip.new
  end

  def create
    newBlip = Blip.new(params[:blip])
    newBlip.gid = 1                 # TODO change from one to cookies[:gid]
    newBlip.lat = newBlip.lat.to_i  # Get rid of quotes
    newBlip.lng = newBlip.lng.to_i  # Get rid of quotes
    jsonBlip = newBlip.to_json      # Convert to JSON

    # Make post request to server
    c = Curl::Easy.http_post("localhost:9000/api/v1/blip", jsonBlip   
    ) do |curl|
      curl.headers['Accept'] = 'application/json'
      curl.headers['Content-Type'] = 'application/json'
      curl.headers['Api-Version'] = '2.2'
    end

    redirect_to(:action => index)
  end

  def edit
    blipRequest = Curl.get("localhost:9000/api/v1/blip/#{params[:id]}")
    blipHash = JSON.parse(blipRequest.body_str)
    blipHash.delete "id"
    @blip = Blip.new(blipHash)
  end

  def update
  end

  def show
  end

  def index
  end

  def destroy
  end
end
