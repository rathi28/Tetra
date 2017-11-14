require_relative Rails.root.join("lib/grotto/browser/grid_utilities.rb")
require "minitest/autorun"
##
# Unit tests for the methods of the GridUtilities class
describe 'grid_test' do
	it "should find hub successfully" do
		assert GridUtilities.is_hub_online?(), 'Online hub returned false'
	end

	it "should fail to find hub" do
		refute GridUtilities.is_hub_online?(port: '0404'), 'Offline hub returned true'
	end

	it "should find node successfully" do
		assert GridUtilities.is_node_online?(), 'Online node returned false'
	end

	it "should fail to find node" do
		refute GridUtilities.is_node_online?(port: '0404'), 'Offline node returned true'
	end

	it "should get a list of Browsers and their available sessions" do
		assert GridUtilities.get_browsers, 'Offline node returned true'
	end

	it "should get an entry for chrome" do
		assert GridUtilities.browser_available('grid-chrome'), 'chrome browsers not available'
	end

	it "should get an entry for firefox" do
		assert GridUtilities.browser_available('grid-firefox'), 'firefox browsers not available'
	end

	it "should get an entry for internet explorer" do
		assert GridUtilities.browser_available('grid-ie'), 'firefox browsers not available'
	end
end