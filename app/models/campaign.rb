class Campaign < ActiveRecord::Base
	has_many :offerdata

  # maps to Campaigns table in database

  # setup filter methods for sorting campaign information. shortcut to creating WHERE statements in controller.
  scope :brand, -> (brand) { where brand: brand }
  scope :uci, -> (uci) { where uci: uci }
  scope :campaign, -> (campaign) { where grcid: campaign }
  scope :environment, -> (environment) { where environment: environment }
  scope :platform, -> (experience) { where experience: experience }
  scope :realm, -> (realm) { where realm: realm }
end