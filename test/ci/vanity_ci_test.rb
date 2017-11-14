require 'ci/ci_helper'
include CITesting

##
# Continuous Integration wrapper for Vanity suites
# This example can be reused for both Pixel and UCI tests

describe "CI Vanity Test" do

	# grabs the recurring schedule that is used for CI testing.
	suite = setup_ci_vanity_test(RecurringSchedule.find(22))

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