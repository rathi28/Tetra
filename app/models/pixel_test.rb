class PixelTest < ActiveRecord::Base
	has_many :test_urls, dependent: :destroy

  	validates :testname, presence: true
	# setup filter methods for sorting PixelTest information. shortcut to creating WHERE statements in controller.
	scope :environment, -> (environment) { where environment: environment }
	scope :testtype, -> (testtype) { where testtype: testtype }
end
