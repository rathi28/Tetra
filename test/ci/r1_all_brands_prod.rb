require 'ci/ci_helper'
include CITesting
##
# Continuous Integration wrapper for Buyflow suites
# this example can be reused for Offercode tests

describe "r1_all_brands_prod" do


	# grabs the recurring schedule that is used for CI testing.
	suite = setup_ci_buyflow_test(RecurringSchedule.find(1))

	# loop through test cases
	suite.testruns.each do |testrun|

		# Initialize test case
		it "Buyflow test for #{testrun.Brand}" do
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
					assert(testrun.result == 'Pass', "Buyflow test ##{testrun.id} failed - see Tetra for details")

					# stop looping
					testing = false
				end
			end
		end
	end
end