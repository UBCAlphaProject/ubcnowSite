class Blip 
  # These includes/extends are needed for form_for to work 
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :gid, :title, :summary, :link, :startTime, :endTime, :address, :lat, :lng

  # TODO MAKE SURE VALIDATIONS MATCH FINAL MODEL 

  validates :title, presence: true

  validates :title,       length: {maximum: 255}
  validates :summary,     length: {maximum: 255}
  validates :link,        length: {maximum: 255}
  validates :startTime,   length: {maximum: 255}
  validates :endTime,     length: {maximum: 255}
  validates :address,     length: {maximum: 255}

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
