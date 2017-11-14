require "minitest/autorun"
require 'test_helper'
PROJECT_HOME = 'C:\Projects\magenic_automation\Tetra'
db_config = YAML::load( File.open("#{PROJECT_HOME}/config/database.yml"))
db_config["development"]['password'] = ENV['TETRA_DATABASE_PASSWORD']
ActiveRecord::Base.establish_connection(db_config["development"])
require_relative Rails.root.join("lib/grotto/import.rb")
require_relative Rails.root.join("app/helpers/testsuites_helper.rb")
require_relative Rails.root.join("app/helpers/pixels_helper.rb")
require_relative Rails.root.join("app/jobs/test_launcher.rb")
require_relative Rails.root.join("app/models/test_suites.rb")
require_relative Rails.root.join("app/models/test_step.rb")
require_relative Rails.root.join("app/models/test_run.rb")
require_relative Rails.root.join("app/models/admin.rb")
require_relative Rails.root.join("app/models/user.rb")
require 'pry'