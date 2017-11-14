=begin
	The test 
=end
require "minitest/autorun"
require 'test_helper'
require 'environment_helper.rb'
require 'pry'

require "#{PROJECT_HOME}/app/models/testrun.rb"

class ADAuthTest < ActiveSupport::TestCase

	include Adauth::Rails::Helpers

	# !! please verify these first if this test suite fails !!
	digital_creds = {
		username: "digitalqaautomation",
		password: "DQAAgr2015$" # this may need updating occasionally when expired. 
	}
	wrong_password = "garbage?"


	test "should login successfully" do
		ldap_user 	= Adauth.authenticate(digital_creds[:username], digital_creds[:password])
		assert ldap_user, "User was not able to login"
	end


	test "should not login successfully" do
		ldap_user	= Adauth.authenticate(digital_creds[:username], wrong_password)
		refute ldap_user, "User was able to login"
	end


end