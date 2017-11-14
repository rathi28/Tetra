class VanityUciSuite < ActiveRecord::Base
	has_many :test_urls, dependent: :destroy
end
