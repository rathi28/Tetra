##
# GR Testing Module, which contains all the test cases needed to handle running tests
# Look here for the test case scripts used to run tests
module GRTesting
  ##
  # This test case is the base for all the other test cases related to web browser testing
  class WebTest < TestCase

    # includes the page models created for the T5 framework
    include T5

    # @!attribute [rw] browser 
    #   A {http://www.rubydoc.info/github/jnicklas/capybara/Capybara/Session Capybara::Session}
    #   @return [Capybara::Session] 

    attr_accessor :browser

    # @!attribute [rw] page
    #   @return [WebPage] A variable to hold current Page Model
    #   @see WebPage

    attr_accessor :page

    # @!attribute [rw] browsertype 
    #   String for controlling the type of browser returned from {BrowserFactory.create_browser} Method
    #   @return [String] The String representing the {BrowserFactory} browser type
    #   @see BrowserFactory 

    attr_accessor :browsertype

    ##
    # Initialize the test case, and set the browsertype, and store the browsertype in the report object
    # @param [String] title A title for the test case, in most cases not used.
    # @param [String] browser String representation for the browser needed.
    # @param [Integer] id The ID for the test case for the database

    def initialize(title: 'Testcase', browser: 'ie11', id: nil)
      # call the test case super method
      super(title: title, id: id)
      @browsertype        = browser
      @report.driver      = @browsertype
    end

    ##
    # Test steps to be executed before a test
    # @note For the WebTest TestCase this includes browser creation based on the stored browsertype

    def before
      puts "webtest before"
      super()
      # Create a browser instance and store it in the browser class variable
      @browser = BrowserFactory.create_browser(@browsertype)
      puts @browser
      puts "get session ip"
      @report.remote_url  = GridUtilities.get_session_ip(session: @browser)
      puts @report.remote_url
      puts "done webtest before"
    end
    ##
    # Test steps to be executed during a test
    def execute
      super()
    end
    ##
    # Test steps to be executed after test completion
    # @note For the WebTest TestCase this includes closing the browser, or displaying an error if the browser failed to close
    def after
      super()
      soft_browser_quit()
    end

    ##
    # Tries to close browser, but doesn't error if it fails to.
    def soft_browser_quit()
      begin
        # Close the Capybara Browser Session if possible
        @browser.driver.quit
      rescue => e
        # Display an error if the Capybara Session could not be closed out
        e.display
      end
    end
  end
end