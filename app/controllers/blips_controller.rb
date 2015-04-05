class BlipsController < ApplicationController
  def new
    @blip = Blip.newBlip                                                # make a new blip
  end

  def create
    newBlip = Blip.new(params[:blip])
    newBlip.gid = 1                                                     # TODO change from one to cookies[:gid]
    newBlip.lat = newBlip.lat.to_i                                      # get rid of quotes
    newBlip.lng = newBlip.lng.to_i                                      # get rid of quotes
    jsonBlip = newBlip.to_json                                          # convert to JSON

    # Make post request to server in the JSON format
    c = Curl::Easy.http_post("localhost:9000/api/v1/blip", jsonBlip   
    ) do |curl|
      curl.headers['Accept'] = 'application/json'
      curl.headers['Content-Type'] = 'application/json'
      curl.headers['Api-Version'] = '2.2'
    end

    redirect_to(:action => index)                                       # redirect to table with all blips
  end

  def edit
    blipRequest = Curl.get("localhost:9000/api/v1/blip/#{params[:id]}") # make a request for the blip that we will be editing
    @blipHash = JSON.parse(blipRequest.body_str)                        # convert to JSON
    @blipHash.delete "id"                                               # delete ID from the hash because blips do not have that field
    @blip = Blip.new(@blipHash)                                         # this will pre-populate the form
  end

  def update
    editedBlip = Blip.new(params[:blip])                                # get updated params from edit-form
    editedBlip.lat = editedBlip.lat.to_f if editedBlip.lat.is_a? String # convert "lat" to lat (get rid of quotes)
    editedBlip.lng = editedBlip.lng.to_f if editedBlip.lng.is_a? String # convert "lng" to lng (get rid of quotes)

    jsonBlip = editedBlip.to_json                                       # convert to JSON

    # Make put request to server in JSON format
    c = Curl::Easy.http_put("localhost:9000/api/v1/blip/#{params[:id]}", jsonBlip   
    ) do |curl|
      curl.headers['Accept'] = 'application/json'
      curl.headers['Content-Type'] = 'application/json'
      curl.headers['Api-Version'] = '2.2'
    end    

    redirect_to(:action => index)                                       # redirect to table with all blips
  end

  def show
  end

  def index
  end

  def destroy
  end
end
