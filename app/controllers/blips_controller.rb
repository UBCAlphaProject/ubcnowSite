class BlipsController < ApplicationController
  def new
    @blip = Blip.new                                                                      # make a new blip
  end

  def create
    validStartTime = validTimeHashHelper(params[:blip], "startTime")
    validEndTime   = validTimeHashHelper(params[:blip], "endTime")

    # Time Validity must be checked seperately: 
    # If the start and end times are valid, get rid of the datetime_select time tags
    # and put in an epoch time, if it isnt valid render the form with an error message
    if(validStartTime && validEndTime) 
      cleanParams = cleanHash(params[:blip])                                              # get rid of all key-value pairs where the value is "" 
      # If it was valid but all the values were "", then the cleanHash() would 
      # have already gotten rid of all the time tags and there is no need to do 
      # anything. On the other hand, if it was valid and had a time, then all the time 
      # tags must be removed and an epoch time must be added
      if(cleanParams.has_key?("startTime(1i)"))                                           # check if it had a startTime
        cleanParams[:startTime] = getEpoch(cleanParams, "startTime")                      # set the epoch start time
        cleanParams = removeTimeTags(cleanParams, "startTime")                            # get rid of all time tags for startTime
      end

      if(cleanParams.has_key?("endTime(1i)"))                                             # check if it had an endTime
        cleanParams[:endTime]   = getEpoch(cleanParams, "endTime")                        # set the epoch endTime
        cleanParams = removeTimeTags(cleanParams,"endTime")                               # get rid of all time tags for endTime
      end
    else
      ## If both times not valid: save valid datetime if one is valid, remove time tags, go
      ## back to the new form. Invalid datetimes will be erased and highlighted in red
      
      cleanParams = cleanHash(params[:blip])                                              # get rid of all key-value pairs where the value is "" 

      # If the times are valid and not nil then remember them so the datetime 
      # auto-fills to their values, otherwise will be blank 
      if(validStartTime && cleanParams.has_key?("startTime(1i)")) 
        cleanParams["startTime"] = Time.at(getEpoch(cleanParams, "startTime") / 1000)
      end
      if(validEndTime && cleanParams.has_key?("endTime(1i)"))
        cleanParams["endTime"] = Time.at(getEpoch(cleanParams, "endTime") / 1000)
      end

      # Get rid of the time tags (no exceptions thrown if tags not there)
      cleanParams = removeTimeTags(cleanParams, "startTime")
      cleanParams = removeTimeTags(cleanParams, "endTime")

      @blip = Blip.new(cleanParams)                                                                  # create the blip 
      @blip.valid?                                                                                   # generate all the other error messages as well
      @blip.errors[:startTime] = "must be blank or complete" unless validStartTime                   # if the start time is wrong add the error messages
      @blip.errors[:endTime]   = "must be blank or complete" unless validEndTime                     # if the end time is wrong add the error messages
      
      render :action => "new"                                                                        # render the new form
      return
    end

    newBlip = Blip.new(cleanParams)                                                                  # create the blip to check for validations / convert to json

    # Make sure that the blip is valid (checks everything but time), otherwise 
    # go back to the new view and render the errors. @blip will contain the errors
    unless newBlip.valid? 
      @blip = newBlip
      @blip.startTime = Time.at(@blip.startTime / 1000) unless @blip.startTime == nil
      @blip.endTime = Time.at(@blip.endTime / 1000) unless @blip.endTime == nil
      render :action => 'new'
      return
    end

    ## At this point the blip should be valid in all ways:

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

    @blip.startTime = Time.at(@blip.startTime / 1000) unless @blip.startTime == nil
    @blip.endTime = Time.at(@blip.endTime / 1000) unless @blip.endTime == nil
  end

  def update
    ## Behaviour very similar to create action

    blipRequest = Curl.get("#{HOST}:#{PORT_NUMBER}/api/v1/blip/#{params[:id]}")            # make a request for the original blip
    originalBlipHash = JSON.parse(blipRequest.body_str)                                    # convert from JSON

    originalStartTime = originalBlipHash["startTime"] / 1000 unless originalBlipHash["startTime"] == nil     # original start time    
    originalEndTime   = originalBlipHash["endTime"] / 1000 unless originalBlipHash["endTime"] == nil         # original end time

    validStartTime = validTimeHashHelper(params[:blip], "startTime")
    validEndTime   = validTimeHashHelper(params[:blip], "endTime")

    # Time Validity must be checked seperately: 
    # If the start and end times are valid, get rid of the datetime_select time tags
    # and put in an epoch time, if it isnt valid render the form with an error message
    if(validStartTime && validEndTime) 
      cleanParams = cleanHash(params[:blip])                                              # get rid of all key-value pairs where the value is "" 
      # If it was valid but all the values were "", then the cleanHash() would 
      # have already gotten rid of all the time tags and there is no need to do 
      # anything. On the other hand, if it was valid and had a time, then all the time 
      # tags must be removed and an epoch time must be added
      if(cleanParams.has_key?("startTime(1i)"))                                           # check if it had a startTime
        cleanParams[:startTime] = getEpoch(cleanParams, "startTime")                      # set the epoch start time
        cleanParams = removeTimeTags(cleanParams, "startTime")                            # get rid of all time tags for startTime
      end

      if(cleanParams.has_key?("endTime(1i)"))                                             # check if it had an endTime
        cleanParams[:endTime]   = getEpoch(cleanParams, "endTime")                        # set the epoch endTime
        cleanParams = removeTimeTags(cleanParams,"endTime")                               # get rid of all time tags for endTime
      end
    else
      ## If both times not valid: save valid datetime if one is valid, remove time tags, go
      ## back to the edit form. Invalid datetimes will be set to original values and highlighted in red
      
      cleanParams = cleanHash(params[:blip])                                              # get rid of all key-value pairs where the value is "" 

      # If the times are valid and not nil then remember them so the datetime 
      # auto-fills to their values, otherwise set them to the original times
      if(validStartTime) 
        if cleanParams.has_key?("startTime(1i)")
          cleanParams["startTime"] = Time.at(getEpoch(cleanParams, "startTime") / 1000)
        end
      else
        cleanParams["startTime"] = Time.at(originalStartTime) unless originalStartTime == nil
      end
      
      if(validEndTime)
        if cleanParams.has_key?("endTime(1i)")
          cleanParams["endTime"] = Time.at(getEpoch(cleanParams, "endTime") / 1000)
        end
      else
        cleanParams["endTime"] = Time.at(originalEndTime) unless originalEndTime == nil   
      end


      # Get rid of the time tags (no exceptions thrown if tags not there)
      cleanParams = removeTimeTags(cleanParams, "startTime")
      cleanParams = removeTimeTags(cleanParams, "endTime")

      @blip = Blip.new(cleanParams)                                                                  # create the blip 
      @blip.valid?                                                                                   # generate all the other error messages as well
      @blip.errors[:startTime] = "must be blank or complete" unless validStartTime                   # if the start time is wrong add the error messages
      @blip.errors[:endTime]   = "must be blank or complete" unless validEndTime                     # if the end time is wrong add the error messages
     
      render :action => "edit"                                                                       # render the edit form
      return
    end

    newBlip = Blip.new(cleanParams)                                                                  # create the blip to check for validations / convert to json

    # Make sure that the blip is valid (checks everything but time), otherwise 
    # go back to the edit view and render the errors. @blip will contain the errors
    unless newBlip.valid? 
      @blip = newBlip
      @blip.startTime = Time.at(@blip.startTime / 1000) unless @blip.startTime == nil
      @blip.endTime = Time.at(@blip.endTime / 1000) unless @blip.endTime == nil
      render :action => 'edit'
      return
    end

    ## At this point the blip should be valid in all ways:

    newBlip.gid = 1                                                                       # TODO change from one to cookies[:gid]
    newBlip.lat = newBlip.lat.to_f if newBlip.lat.is_a? String                            # get rid of quotes
    newBlip.lng = newBlip.lng.to_f if newBlip.lng.is_a? String                            # get rid of quotes
        
    jsonBlip = newBlip.to_json                                                            # convert to JSON

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
