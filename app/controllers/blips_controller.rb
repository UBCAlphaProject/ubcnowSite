class BlipsController < ApplicationController
  def new
    @blip = Blip.new                                                                     # make a new blip
  end

  def create
    cleanParams = cleanHash(params[:blip])                                               # get rid of all key-value pairs where the value is "" 
    newBlip = Blip.new(cleanParams)

    # Make sure that the blip is valid, otherwise go back to the new view 
    # and render the errors. @blip will contain the errors
    unless newBlip.valid? 
      @blip = newBlip
      render :action => 'new'
      return
    end


    newBlip.gid = 1                                                                       # TODO change from one to cookies[:gid]
    newBlip.lat = newBlip.lat.to_f if newBlip.lat.is_a? String                            # get rid of quotes
    newBlip.lng = newBlip.lng.to_f if newBlip.lng.is_a? String                            # get rid of quotes
    newBlip.startTime = newBlip.startTime.to_i if newBlip.startTime.is_a? String          # get rid of quotes TODO TIME FORMAT FIX
    newBlip.endTime = newBlip.endTime.to_i if newBlip.endTime.is_a? String                # get rid of quotes TODO TIME FORMAT FIX
        
    jsonBlip = newBlip.to_json                                                            # convert to JSON

    # Make post request to server in the JSON format
    c = Curl::Easy.http_post("#{HOST}:#{PORT_NUMBER}/api/v1/blip", jsonBlip   
    ) do |curl|
      curl.headers['Accept'] = 'application/json'
      curl.headers['Content-Type'] = 'application/json'
      curl.headers['Api-Version'] = '2.2'
    end

    redirect_to(:action => :index)                                                         # redirect to table with all blips
  end

  def edit
    blipRequest = Curl.get("#{HOST}:#{PORT_NUMBER}/api/v1/blip/#{params[:id]}")            # make a request for the blip that we will be editing
    @blipHash = JSON.parse(blipRequest.body_str)                                           # convert from JSON
    @blipHash.delete "id"                                                                  # delete ID from the hash because blips do not have that field
    @blip = Blip.new(@blipHash)                                                            # this will pre-populate the form
  end

  def update
    cleanParams = cleanHash(params[:blip])                                                 # get rid of all key-value pairs where the value is "" 
    editedBlip = Blip.new(cleanParams)                                                     # get updated params from edit-form

    editedBlip.lat = editedBlip.lat.to_f if editedBlip.lat.is_a? String                    # get rid of quotes
    editedBlip.lng = editedBlip.lng.to_f if editedBlip.lng.is_a? String                    # get rid of quotes
    editedBlip.startTime = editedBlip.startTime.to_i if editedBlip.startTime.is_a? String  # get rid of quotes TODO TIME FORMAT FIX
    editedBlip.endTime = editedBlip.endTime.to_i if editedBlip.endTime.is_a? String        # get rid of quotes TODO TIME FORMAT FIX


    jsonBlip = editedBlip.to_json                                                          # convert to JSON

    # Make put request to server in JSON format
    c = Curl::Easy.http_put("#{HOST}:#{PORT_NUMBER}/api/v1/blip/#{params[:id]}", jsonBlip   
    ) do |curl|
      curl.headers['Accept'] = 'application/json'
      curl.headers['Content-Type'] = 'application/json'
      curl.headers['Api-Version'] = '2.2'
    end    

    redirect_to(:action => :index)                                                        # redirect to table with all blips
  end

  def show
  blipRequest = Curl.get("#{HOST}:#{PORT_NUMBER}/api/v1/blip/#{params[:id]}")             # make a request for the blip that we will be editing
    @blipHash = JSON.parse(blipRequest.body_str)                                          # convert from JSON
  end

  def index
    blipsRequest = Curl.get("http://#{HOST}:#{PORT_NUMBER}/api/v1/blip")                  # make a request for the users blips (same group)
    @blipsArray = JSON.parse(blipsRequest.body_str)                                       # convert from JSON
  end

  def destroy
    Curl::Easy.http_delete("#{HOST}:#{PORT_NUMBER}/api/v1/blip/#{params[:id]}")           # make a request to delete that blip
    redirect_to(:action => :index)                                                        # go back to the index pagerails
  end
end
