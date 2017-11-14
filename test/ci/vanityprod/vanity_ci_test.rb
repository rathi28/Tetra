require "minitest/autorun"
require 'test_helper'

# initialize in the production/development test environment
PROJECT_HOME = 'C:\Projects\magenic_automation\Tetra'
db_config = YAML::load( File.open("#{PROJECT_HOME}/config/database.yml"))
db_config["development"]['password'] = ENV['TETRA_DATABASE_PASSWORD']
ActiveRecord::Base.establish_connection(db_config["development"])
require_relative Rails.root.join("lib/grotto/import.rb")
require_relative Rails.root.join("app/jobs/test_launcher.rb")
require 'pry'


# include the setup funcitons
include TestsuitesHelper
include PixelsHelper


##
# function for setting up a vanity test in CI

def setup_ci_test(test)
    testtype = test['testtype'].downcase
    params = {}
    params[:browser]            = test.driver
    params[:driver]            	= test.driver
    params[:platform]           = test.platform
    params[:testsuite]          = test.pixel_suite
    params[:email]              = test.email
    params[:scheduleid]         = test.id
    suite = generate_vanity_test(params, 'Scheduled')
    return suite
end

##
# Continuous Integration wrapper for Vanity suites

describe "CI Vanity Test" do

	# grabs the recurring schedule that is used for CI testing.
	suite = setup_ci_test(RecurringSchedule.find(22))

	# loop through test cases
	suite.test_runs.each do |testrun|

		# Initialize test case
		it "Checking vanity url: #{testrun.url}" do
			# set flag to true
			testing = true
			# loop until test case is complete. Need to do this to report back to jenkins
			while(testing == true)
				# sleep so we aren't constantly polling
				sleep(3)
				# check the testrun again
				testrun.reload
				# check if complete 
				if(testrun.status == "Complete")
					# check if the test run passed
					assert(testrun.result == 1, "Vanity Test ##{testrun.id} failed - see Tetra for details")
					# stop looping
					testing = false
				end
			end
		end
	end
end