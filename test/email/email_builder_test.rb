require "minitest/autorun"
require 'test_helper'
require 'environment_helper.rb'
require 'pry'

require "#{PROJECT_HOME}/app/models/testrun.rb"

class EmailBuilderTest < ActiveSupport::TestCase
	email_target = "ssankara@guthy-renker.com"

	test "should send test_run results" do
		suite = test_runs(:vanityrunone).test_suites
		email = EmailBuilder.new(email_target)
      	email.title         = "#{suite['Test Suite Name']} #{suite['SuiteType']} Test #{suite.Environment} for #{suite.Browser}"
      	email.body          = email.create_pixel_email(suite.id)
      	email.deliver
	end

	test "should send testrun results" do
		suite = TestSuites.find(283)
        email = EmailBuilder.new(suite.emailnotification)
        email.title         = "#{suite.Brand} #{suite.Campaign} OfferCode Test #{suite.Environment} for #{suite.Browser}"
        email.body          = email.create_buyflow_email_body(suite.id)
        email.deliver
	end
end