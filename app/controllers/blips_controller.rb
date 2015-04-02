class BlipsController < ApplicationController
  def new
    @blip = Blip.new
  end

  # Make a hash with all the values from the form, convert it to json,
  # then send the post request, and lastly redirect to index to see all
  # the blips 
  def create
    newBlip = {}
    # TODO GID will be taken from cookies hash and added here to newBlip
    # Need to recieve the GID to be able to implement/test this, in the 
    # meantime using the value 0 for all group IDs 
    newBlip[:gid]     = 1
    newBlip[:title]   = params[:title]
    newBlip[:summary] = params[:summary]
    newBlip[:link]    = params[:link]
    newBlip[:time]    = params[:time]
    newBlip[:lat]     = params[:lat].to_i
    newBlip[:lng]     = params[:lng].to_i
    jsonBlip = newBlip.to_json

    c = Curl::Easy.http_post("localhost:9000/api/v1/blip", jsonBlip   
    ) do |curl|
      curl.headers['Accept'] = 'application/json'
      curl.headers['Content-Type'] = 'application/json'
      curl.headers['Api-Version'] = '2.2'
    end

    # DEBUG
    puts "#{c.body_str}"

    redirect_to(:action => index)
  end

  def edit
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
