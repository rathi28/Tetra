=begin

Class:

BrowserstackAPI

Description: 

API Class for accessing the browserstack API and getting the status of the browserstack system, to show downtime and to catch some issues in advance.

=end
# Require Gems (Libraries)

# needed to create requests for API methods
require 'open-uri'

# needed to parse json from API response
require 'json'

# Browserstack API Class
class BrowserstackAPI
  # Stores the max sessions available to account
  attr_reader :sessions_limit
  # stores the API endpoint value
  @api_url = nil

  # initializes the API object, and stores the session limit
  def initialize(user: 'christophermosel2', pass_key: 'DfURxDmhxpnQqZ2hyS6z')
    # set username
    @username = user
    # set pass_key
    @pass_key = pass_key
    # set the endpoint of BrowserStack API
    @api_url = "http://api.browserstack.com/3/"

    # get max number of sessions
    @sessions_limit = self.get_status['sessions_limit']
  end

  def get_status
    # get response for browserstack account status

    response = open(@api_url + '/status', :http_basic_authentication => [@username, @pass_key])

    # check for request failure
    if(response.status[0] != '200')
      raise 'Failed to read API'
    end
    # parse the status from the response
    status = JSON.parse(response.read)

    # ensure the return of the status properly from method
    return status
  end

  # returns the number of available sessions
  def get_available_slots
    # Return the number of unused sessions
    return @sessions_limit - get_status['running_sessions']
  end
end

