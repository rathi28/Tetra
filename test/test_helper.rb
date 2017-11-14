ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

begin
	load "#{Rails.root}/db/seeds.rb" 
rescue

end
class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  self.use_instantiated_fixtures = true

  	# Add more helper methods to be used by all tests here...


  	##
  	# Use Chrome for Capybara for testing
  	# This is just for the internal tests for regression testing the automation suite
  	def use_chrome_to_test
  		client = Selenium::WebDriver::Remote::Http::Default.new
      	client.timeout = 120
	    Capybara.register_driver :chrome do |app|
	        Capybara::Selenium::Driver.new(
	          app,
	          :browser => :chrome,
	          :http_client => client,
	          :switches => %w[—test-type -allow-running-insecure-content])
	    end
	    Capybara.javascript_driver = :chrome
		Capybara.current_driver = :chrome
  	end
  	
  	#login to system for simple test
  	def login_to_tetra
		session[:current_user_id] = users(:one).id

		# redirect_to "/login"
		# assert_response :success
		# post_via_redirect "/login", username: 'cmoseley', password: 'insecured'
		# assert_equal '/', path
		# assert_empty flash
	end

	# login to system for UI test
	def login_to_tetra_capy
		#session[:current_user_id] = 0

		click_on 'Admin'
		fill_in "username", :with => 'cmoseley'
		fill_in "password", :with => 'insecured'
		click_on 'Sign in'
	end

	# logout for UI test
	def logout_of_tetra
		click_on "logout"
	end
end
