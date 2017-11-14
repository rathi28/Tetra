require 'mysql2'
require 'yaml'
require 'pry'

# Require any database models neeeded for this abstraction

require Rails.root.join('app/models/locator.rb')
require Rails.root.join('app/models/campaign.rb')
require Rails.root.join('app/models/offerdatum.rb')
require Rails.root.join('app/models/brands.rb')
require Rails.root.join('app/models/orderforms.rb')
require Rails.root.join('app/models/brandurldata.rb')
require Rails.root.join('app/models/browsertypes.rb')
require Rails.root.join('app/models/testrun.rb')
require Rails.root.join('app/models/test_step.rb')
require Rails.root.join('app/models/test_run.rb')
require Rails.root.join('app/models/delayed_job.rb')
require Rails.root.join('app/models/grid_processes.rb')

##
# Abstraction for the tables needed for testing. Uses the Rails Model method to keep connections from going away.
class GRDatabase

  ##
  # @deprecated Removed due to the timeout issue. Method now redirects to a warning to change whatever is using it.
  # Method for accessing database object directly
  # DEPRECIATED DUE TO TIMEOUT ISSUE
  # USE MODELS IF ACCESS NEEDED TO DATABASE
  def self.db
    raise "REMOVED METHOD - CHANGE THIS TO ACTIONRECORD"
  end

  
  def self.get_browsertypes(browser)
    Browsertypes.where(browser: browser)
  end

  def self.get_testruns(suite)
    return Testrun.where(test_suites_id: suite)
  end

  def self.get_browserstack_capabilities()
    return ::YAML.load_file(Rails.root.join('lib/grotto/data/browserstack.yml'))
  end

  def self.get_orderform(form)
    return Orderforms.where(:orderformname => form)
  end

  def self.get_brand_data(brand)
    return Brandurldata.where(:Brand => brand)
  end

  def self.get_offer_data(brand, campaign, platform, server)
    self.db
    @db.query "select * from offerdata where campaign = '#{campaign}' and #{server} = 1 and brand = '#{brand}' and (#{platform} = 1)"
  end

  def self.get_offer(offercode, brand, campaign, platform, server)
    Offerdatum.where(:OfferCode => offercode, :Brand => brand, platform.to_sym => '1', server.to_sym => '1', :campaign => campaign)
  end

  def self.get_core_campaigns(server)
    Campaign.where(:core => 1, :environment => server)
  end

  def self.get_active_campaigns(brand)
    Campaign.where(:brand => brand, :active => 1)
  end

  def self.get_all_locators(step, brand, offer)
    Locator.where(:brand => brand, :step => step, :offer => offer)
  end

  def self.get_locator_step(locator)
    result = []
    result = Locator.where(:css => locator)
    if(result.entries[0].nil?)
      raise 'locator is not in database ("' + locator + '")'
    else
      return result.entries[0]['step']
    end
  end

  def self.get_campaign_data(brand, id, server, experience, realm)
    data = Campaign.where(:grcid => id, :brand => brand, :environment => server, :experience => experience, :realm => realm)
    return data
  end

  def self.validate_locators(locators)
    invalid = 0
    invalid_locators = []
    valid_locators = {}
    locators.each do |locator|
      result = Locator.where(:css => locator)
      if(result.entries[0].nil?)
        new_loc = Locator.new(:css => locator)
        new_loc.save!
        invalid = 1
        invalid_locators.push locator
      else
        valid_locators[locator] = result.entries[0]
      end
    end
    if(invalid == 1)
      raise "Unknown Locators - Some locators were not identified - Check Table for unidentified locators"
    else
      return valid_locators
    end
  end
end
