module BlipsHelper

  def timeHumanReadable(epochInt)
  	return nil if epochInt == nil 							# Time.at cant handle nil value so return nil if int is nil
    epochNoMili = epochInt / 1000							# Get rid of miliseconds for ease of use with ruby Time class
    return Time.at(epochNoMili).asctime						# asctime formats a nice string for you
  end

end
