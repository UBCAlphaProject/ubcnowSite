class BlipsController < ApplicationController
  def new
    @blip = Blip.new
  end

  def create
    #TODO
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
