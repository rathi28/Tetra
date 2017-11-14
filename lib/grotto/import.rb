##
# This file is for importing all the files needed for the test workers.
# Test workers do not load the entire environment, and so need individual files to be imported.



# Not sure if needed anymore, testing needed before commiting to removal
require 'mysql2'
require 'gmail'


# utilities used in the course of testing

# browser creating class
require_relative "browser/browser_factory.rb"

# browserstack api
require_relative "browser/browserstack_api.rb"

# URL factory for creating generated URLs on the fly
require_relative "browser/url_factory.rb"

# Grid Utilities for checking status of Selenium Grid Nodes
require_relative "browser/grid_utilities.rb"

# refactored old database class for before we switched to rails UI to drive testing
require_relative "database/database.rb"

# additional error handling classes for custom situations
require_relative "better_errors.rb"



# Page Models used during testing

require_relative "page_models/webpage.rb"
require_relative "page_models/t5/t5.rb"
require_relative "page_models/t5/marketing.rb"
require_relative "page_models/t5/sas.rb"
require_relative "page_models/t5/cart.rb"
require_relative "page_models/t5/confirmation_page.rb"

#



# Reporting classes for emailing the user and closing out test

require_relative "reports/gr_reporting.rb"
require_relative "reports/email_builder.rb"

#



# Test Case classes - These are the scripts which do the actual work

require_relative "gr_testing/gr_testing.rb"
require_relative "gr_testing/test_case.rb"
require_relative "gr_testing/web_test.rb"
require_relative "gr_testing/buyflow_test.rb"
require_relative "gr_testing/vanity_test.rb"
require_relative "gr_testing/pixel_test.rb"
require_relative "gr_testing/uci_test.rb"
require_relative "gr_testing/seo_test.rb"

#

