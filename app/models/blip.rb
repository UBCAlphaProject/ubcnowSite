class Blip 
  # These includes/extends are needed for form_for to work 
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :gid, :title, :summary, :link, :time, :address, :lat, :lng

  # Constructor which will take in a hash and set all the respective 
  # attributes 
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
  
  # Method needed for form_for to work 
  def persisted?
    false
  end

end
