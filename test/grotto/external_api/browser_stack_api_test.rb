require_relative Rails.root.join("lib/grotto/browser/browserstack_api.rb")
require "minitest/autorun"
require 'pry'

describe "BrowserstackAPI" do
	
	it "can create an API handler instance" do
		assert BrowserstackAPI.new
	end

	it "can check status of API" do
		assert BrowserstackAPI.new.get_status, "Failed to get status of API"
	end

	it "should have sessions_limit from good api" do
		assert BrowserstackAPI.new.sessions_limit, "Couldn't get sessions_limit"
	end

	it "should have get_available_slots from good api" do
		assert BrowserstackAPI.new.get_available_slots, "Couldn't get available slots"
	end

	it "should fail to find a status for bad login" do
		assert_raises OpenURI::HTTPError do
			BrowserstackAPI.new(pass_key: '450').get_status
		end
	end
end