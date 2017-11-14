class Locator < ActiveRecord::Base
  # maps to Locators table in database

  # setup filter methods for sorting Locators information. shortcut to creating WHERE statements in controller
  scope :brand, -> (brand) { where brand: brand }
  scope :step, -> (step) { where step: step }
  scope :css, -> (css) { where css: css }
  scope :offer, -> (offer) { where offer: offer }

  
end