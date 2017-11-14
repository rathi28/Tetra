
# for URI management
require 'uri'

# Class: URL Factory

# Description: This class is for dynamically constructing the urls
#              needed for running tests against the Guthy-Renker 
#              Development, QA, and Production environments.

class URLFactory
  # Holds the configuration data from the database for Test URL construction.
  attr_reader :urls_list

  # <Class Method>
  # returns the urls object for the brand selected
  def self.urls(brand)
    # Downloads the data from the database for environment url pieces for a brand.
    @urls_list = GRDatabase.get_brand_data(brand).entries.first
  end

  # <Class Method>
  # Constructs a new URL based on the parameters given
  #
  def self.generate_url(brand: 'Wen', server: 'qa', campaign: nil, vanity: '', parameters: {}, test: false)
    # stores in the class variable the url object needed for this brand
    self.urls brand # could be replaced with a instance variable?
    server = server.downcase
    
    # Constructs the URL, based on environment
    if(server == "prod")
      url = URI.parse "http://#{@urls_list[server]}.com/"
      parameters = {'mmcore.gm' => '2'}.merge parameters if(test) # MaxyMiser Test override, if needed 
    else
      server_type = (server.include?('dev') ? 'development' : server )
      url = URI.parse "https://storefront:Grcweb123@#{@urls_list[server_type]}.#{server}.#{@urls_list['test_env']}.com/"
      parameters = {'mmcore.gm' => '2'}.merge parameters if(test) # MaxyMiser Test override, if needed 
    end

    # Add a vanity path to the constructed URI object
    url.path = "/" + vanity 

    # Merge in a GRCID if needed.
    parameters = {'grcid' => "#{campaign}"}.merge parameters if(campaign)

    # Add the Query parameters to the URL
    url.query = URI.encode_www_form parameters

    # Return the constructed URL as a string
    return url.to_s
  end
end