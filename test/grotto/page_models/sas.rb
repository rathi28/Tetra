
# require setup to direct to development database
require 'page_model_test_helper.rb'

describe "FlexCartTest" do
	# before all tests preparations
	it "should find an offercode" do
		url 	= "http://www.xout.com/?uci=US-DT-O-AF-LI-60636&mmcore.gm=2"
		campaign_id = 182
		browser = 'local-iphone'
		campaign = Campaign.find(campaign_id)
		offer = campaign.offerdata.where(OfferCode: campaign.default_offercode).first
		page 	= T5::SAS.new(campaign).adapt
		page.browser = BrowserFactory.create_browser(browser)
		page.browser.driver.browser.get(url)
		binding.pry
		# offercode = page.offercode
		# puts offercode.to_s
		# refute_nil(offercode, "This method should return something")
	end
end
