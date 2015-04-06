class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  	##########################################################################
  	# 							   Helpers									 #
  	##########################################################################

  	# Go through the hash and delete all key-value pairs where the value is ""
  	# Returns the hash
	def cleanHash(hash)
		hash.each { |key, value|
			hash.delete "#{key}" if value == ""
		}
		return hash
	end

end
