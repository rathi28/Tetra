# CI Helper - sets up the CI test runs
require "minitest/autorun"
require 'test_helper'

# initialize in the production/development test environment
PROJECT_HOME = 'C:\Sites\magenic_automation\Tetra'
db_config = YAML::load( File.open("#{PROJECT_HOME}/config/database.yml"))
db_config["development"]['password'] = ENV['TETRA_DATABASE_PASSWORD']
ActiveRecord::Base.establish_connection(db_config["development"])
require_relative Rails.root.join("lib/grotto/import.rb")
require_relative Rails.root.join("app/jobs/test_launcher.rb")
require 'pry'

# include the setup functions
include TestsuitesHelper
include PixelsHelper

module CITesting
	##
	# function for setting up a Buyflow test in CI

	def setup_ci_buyflow_test(test)
	    testtype = test['testtype'].downcase
	    params = {}
	    params[:brand]              = test.brand
	    params[:campaign]           = test.grcid
	    params[:server]             = test.environment
	    params[:realm]              = test.realm
	    params[:browser]            = test.driver
	    params[:platform]           = test.platform
	    params[:custom_url]         = test.customurl
	    params[:custom_offer]       = test.customoffer
	    params[:emailnotification]  = test.email
	    params[:scheduleid]         = test.id
	    suite = create_test(params, testtype)
	    return suite
	end


	##
	# function for setting up a vanity test in CI

	def setup_ci_vanity_test(test)
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
end