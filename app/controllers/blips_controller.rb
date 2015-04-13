class BlipsController < ApplicationController
  def new
    @blip = Blip.new                                                                      # make a new blip
  end

  def create
    # Time Validity must be checked seperately: 
    # If the start and end times are valid, get rid of the datetime_select time tags
    # and put in an epoch time, if it isnt valid render the form with an error message
    if(validTimes(params[:blip])) 
      cleanParams = cleanHash(params[:blip])                                              # get rid of all key-value pairs where the value is "" 
      # If it was valid but all the values were "", then the cleanHash() would 
      # have already gotten rid of all the time tags and there is no need to do 
      # anything. On the other hand, if it was valid and had a time, then all the time 
      # tags must be removed and an epoch time must be added
      if(cleanParams.has_key?("startTime(1i)"))                                           # check if it had a time
        cleanParams[:startTime] = getEpoch(cleanParams, "startTime")                      # set the epoch start time
        cleanParams[:endTime]   = getEpoch(cleanParams, "endTime")                        # set the epoch end time
        cleanParams = removeTimeTags(cleanParams)                                         # get rid of all time tags from datetime_select
      end

    else
      # TODO IMPLEMENT INVALID TIME 
    end

    newBlip = Blip.new(cleanParams)                                                       # Create the blip to check for validations / convert to json

    # Make sure that the blip is valid (checks everything but time), otherwise 
    # go back to the new view and render the errors. @blip will contain the errors
    unless newBlip.valid? 
      @blip = newBlip
      render :action => 'new'
      return
    end


    newBlip.gid = 1                                                                       # TODO change from one to cookies[:gid]
    newBlip.lat = newBlip.lat.to_f if newBlip.lat.is_a? String                            # get rid of quotes
    newBlip.lng = newBlip.lng.to_f if newBlip.lng.is_a? String                            # get rid of quotes
        
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

    # Make sure that the blip is valid, otherwise go back to the edit view 
    # and render the errors. @blip will contain the errors
    unless editedBlip.valid? 
      @blip = editedBlip
      render :action => 'edit'
      return
    end

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
