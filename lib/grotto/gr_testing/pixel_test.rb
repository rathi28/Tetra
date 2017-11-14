# make sure to include proxy access library to connect to the browser proxy node
require 'browsermob/proxy'
require 'uri'
##
# GR Testing Module, which contains all the test cases needed to handle running tests
# Look here for the test case scripts used to run tests
module GRTesting
  ##
  # This test case is the base for all the other test cases related to web browser testing
  class PixelTest < TestCase

    # includes the page models created for the T5 framework
    include T5

    # @!attribute [rw] browser 
    #   A {http://www.rubydoc.info/github/jnicklas/capybara/Capybara/Session Capybara::Session}
    #   @return [Capybara::Session] 

    attr_accessor :browser

    # @!attribute [rw] testtype 
    #   @return [testtype] whether this is a confirmation test or some other type of test

    attr_accessor :testtype

    ##
    # @!attribute [rw] platform 
    #   @return [String] Text value for the the platform for this test (desktop, tablet, or mobile)
    attr_accessor :platform

    ##
    # @!attribute [rw] custom_settings
    #   @return [Hash] hash of settings set for this test run
    attr_accessor :custom_settings

    # @!attribute [r] retries
    #   @return [Integer] the number of retries available to this test run 
    attr_reader :retries

    # @!attribute [r] remote_url
    #   @return [String] The IP address of the grid node that ran this test
    attr_reader :remote_url

    # @!attribute [rw] page
    #   @return [WebPage] A variable to hold current Page Model
    #   @see WebPage

    attr_accessor :page

    # @!attribute [rw] browsertype 
    #   String for controlling the type of browser returned from {BrowserFactory.create_browser} Method
    #   @return [String] The String representing the {BrowserFactory} browser type
    #   @see BrowserFactory 

    attr_accessor :url

    # @!attribute [rw] pixelhash 
    # 	Hash containing all the pixels that should be checked, and the values for each is whether or not the pixel should appear or not
    # 	@return [Hash] The hash of all pixels and their values
    attr_accessor :pixelhash

    ##
    # Initialize the test case, and set the browsertype, and store the browsertype in the report object
    # @param [String] title A title for the test case, in most cases not used.
    # @param [String] browser String representation for the browser needed.
    # @param [Integer] id The ID for the test case for the database

    def initialize(title: 'Testcase', browser: 'ie11', pixelhash: nil, id: nil)
      puts "pixel initialize"
      # call the test case super method
      super(title: title, id: id)
      @proxy_ip             = Grid_Processes.where('role = ?', "proxy").first.ip
      @pixelhash			      = pixelhash
      @browsertype        	= browser
      @report.driver      	= @browsertype
    end

    
    # for setting up, or restarting the test

    def setup_resources
      puts "setup resources"
      @proxy = BrowserMob::Proxy::Client.from("http://#{@proxy_ip}:9090")
      case @platform.downcase
       when "mobile"
        @browser = BrowserFactory.grid_browser_mob_firefox_iphone(@proxy)
       when "tablet"
        @browser = BrowserFactory.grid_browser_mob_firefox_ipad(@proxy)
       else
        @browser = BrowserFactory.grid_browser_mob_firefox(@proxy)
       end
      @report.pixel_report  = GRReporting::PixelReport.new()
      #@proxy.new_har "proactiv"
      @proxy.new_har "wen"
    end

    # for cleaning up, restarting the test if error should occur

    def tear_down_resources
      begin
        # Close the Proxy Session if possible
        @proxy.close
      rescue => e
        # Display an error if the Proxy Session could not be closed out
        Rails.logger.info e.message
      end
      
      begin
        # Close the Capybara Browser Session if possible
        
        @browser.driver.quit
      rescue => e
        # Display an error if the Capybara Session could not be closed out
        Rails.logger.info e.message
      end
    end

    ##
    # Test steps to be executed before a test
    # @note For the WebTest TestCase this includes browser creation based on the stored browsertype
    def before
      puts "pixel before"
      super()
      setup_timeout = 0
      begin
        setup_resources
      rescue => e
        # binding.pry
        tear_down_resources
        if setup_timeout < 15
          setup_timeout = setup_timeout + 1
          retry 
        else
          raise e
        end

      end
    end

    ##
    # Test steps to be executed during a test
    def execute
      puts "pixel execute"
      super()
      if(custom_settings['retries'])
        @retries = custom_settings['retries'].to_i
      else
        @retries = 0
      end

      @selenium_timeout = 1
puts "entering execute begin"
      begin
        puts @report.url
        # workarounds for http basic auth login popups
        #auth_workarounds(@report.url)
         # workarounds for http basic auth login popups
        auth_workarounds(@report.url)

        # navigate to the target address for testing
        @browser.driver.browser.get(@report.url)
puts testtype
        # if this is a confirmation page test
        if(testtype.downcase.include?('confirm'))

          # Confirmation handling
          Rails.logger.info 'following purchase flow'
puts "place orders"
          # navigate to the confirmation page
          # place_order
        end

        # time to wait for all page loading to complete
        # waittime = 20

        # wait for all page loading to complete
        # sleep(waittime)

        # save the screenshot from this page
        # @browser.save_screenshot("public/debug/test_run/#{@id}.png")

        
        # save if this page completed reaching the confirmation page
        conf_reached = true # is this used for anything? can be dropped if not
        
        # check if this is a confirmation page
        # if(testtype.downcase.include?('confirm'))
        #   # set the page name to blank
        #   page_name = ''
        #   begin
        #     # get current page name
        #     page_name     = @browser.evaluate_script('mmPageName');
        #     page_name = @browser.evaluate_script('s.pageName') if(!page_name.downcase.include?("conf"));
        #     raise 'wrong page' if(page_name.empty?) # raise error to do more checking
            
        #   rescue => e
        #     begin
        #       begin 
        #         # page name check for realm2
        #         page_name     = @browser.evaluate_script('app.omniMap.PageName') if(page_name.empty?)
        #       rescue => e
        #         found_conf = ""
        #       end
        #       # page name check for supersmile and older pages
        #       page_name     = @browser.evaluate_script('visitorLogData.pageId') if(page_name.empty?)
        #       raise 'wrong page' if(page_name.empty?)
        #     rescue => e

        #     end
        #   end

        #   begin

        #     if(page_name.downcase.include?("conf") == false)
        #       raise "Wrong page"
        #     end
        #   rescue => e
        #     begin
        #       begin
        #         # page name check for supersmile and older pages
        #         found_conf = @browser.evaluate_script('visitorLogData.pageId');
        #       rescue => e
        #         found_conf = ""
        #       end
        #       if(found_conf.downcase.include?("conf"))

        #       else
        #         raise "Wrong page"
        #       end
        #     rescue => e
        #       # if all workarounds fail, raise it again to highest level
        #       raise e
        #     end
        #   end
        # end

        # checking for additional data, disabled unless needed

        # begin
        #   page_campaign = @browser.evaluate_script('mmCampaign');
        #   page_uci      = @browser.evaluate_script('mmUCI');
        # rescue => e

        # end

        # if confirmation test...
        if(testtype.downcase.include?('confirm'))
          # ...get the confirmation number and record in report
          @report.pixel_report.confirmation_number = get_confirmation_number()
          puts "confirmation number"
          puts @report.pixel_report.confirmation_number
        end

        puts "capturing network data"
        # set found to false
        found = false # is this used?

        Rails.logger.info 'capturing page network traffic'

        # pull network data from the proxy used for this test
        entries = @proxy.har.entries
        # entries = @proxy.har
        # puts "traffic entries"
        # puts entries
        # puts "traffic collected"

        Rails.logger.info "Traffic collected"

        # close the browser and proxy, as they aren't needed after this
		    tear_down_resources()

        # iterate through all pixels to be tested
        @pixelhash.each do |pixel|

          # if pixel is expected
          if(pixel.expected == "1")

            # test that it was found
            validate_existing_pixel(entries, pixel)
          else

            # if the pixel wasn't expected, and the test is looking at non-existant pixels as well...
            if(@custom_settings['nonexistant'])

              # check for that the pixel isn't found in network traffic
              validate_nonexisting_pixel(entries, pixel)
            end
          end
        end

        # get the grid url for this tests node
        @remote_url  = GridUtilities.get_session_ip(session: @browser)

        # set the retry flag to false
        reattempt = false

        begin
          # get the TestRun record for this test
          run = TestRun.find(@id)
          # get the test steps for this test
          steps = run.test_steps

          # check for any failed test steps
          failed = steps.where(result: 0)

          # if nothing failed          
          if failed.empty?
            # pass the test case
            run.result = 1

            # otherwise
          else
            # if retries are not available
            if @retries > 0
              # mark as failure, but retry the test
              run.result = 0
              reattempt = true
            else
              # fail the test
              Rails.logger.info "Reattempts Exhausted"
              run.result = 0
            end
          end

          # record the remote url to the test
          run.remote_url = @remote_url.to_s

          # record that the test is complete
		      run.status = "Complete"

          # save this record
          run.save!

        rescue => e
          # catch record failures
      		Rails.logger.info e.message
      		Rails.logger.info e.backtrace
          Rails.logger.info "Failed to update run result"
        end
        # if reattempt is true, then run this test again
        if(reattempt)
          Rails.logger.info "Reattempting!"
          Rails.logger.info "Reattempts lefts - #{@retries}"
          raise "Reattempt this test"
        end
        return true
      rescue RestClient::RequestTimeout => e
        raise e
      rescue Selenium::WebDriver::Error::UnknownError, Net::ReadTimeout => e
        # catch grid traffic related issues
        @selenium_timeout = @selenium_timeout + 1

        tear_down_resources

        if @selenium_timeout < 10
          setup_resources
          retry
        else
          raise e
        end

      rescue => e

        Rails.logger.info "Catching general error  - #{e.message}"
        Rails.logger.info "Retries count = #{@retries}"

        tear_down_resources

        if(@retries > 0)
          @retries = @retries - 1
          setup_resources
          retry
        end
        
        # if we are out of test runs, don't continue
        if e.message.include? "Reattempt this test"
          raise "Reattempts exhausted" # if this is called something is wrong with test, and things should be checked out.
        end

        raise e # raise the error caught to highest level for test case handles
      end
    end

    ##
    # Test steps to be executed after test completion
    # @note For the WebTest TestCase this includes closing the browser, or displaying an error if the browser failed to close
    def after

      super()
	  
  	  begin
        # get the record for this test run
    		run = TestRun.find(@id)
        # mark the test run as complete
    		run.status = "Complete"
        # record total runtime for this test
        run.runtime = @report.runtime
        # record the grid url used for this test if any used
        run.remote_url = @remote_url.to_s
        # record the confirmation number for this test
        run.order_id = @report.pixel_report.confirmation_number

        # Record the errors for this test if present
        begin
          if(@errors.first)
            error_obj = ErrorMessage.new()
            error_obj.class_name = @errors.first.class.to_s
            error_obj.message = @errors.first.message
            error_obj.backtrace = @errors.first.backtrace.join("\n")
            error_obj.test_run_id = run.id
            error_obj.save!
            run.scripterror = @errors.first.class.to_s
            run.result = 0
            run.Notes = @errors.first.message
          end
        rescue => e

        end
        # save the record for this test run
        run.save!
  	  rescue => e
        # print message if run failed to be updated
  		  Rails.logger.info e.message
  	  end
      # clean up any proxy/browser resources used during test
      tear_down_resources
    end

    # def validate_existing_pixel(data:, pixel:)
    #   puts "validating existing pixels"
    #   found = 0
    #   data.save_to "newnetwork.har"
    #   puts "data"
    #   puts data
    #   puts "pixel"
    #   puts pixel
    #   puts data.entries.first.request.url
    #   data.entries.each do |add|
    #     puts "count url"
    #     puts add.request.url 
    #   end
    # end

    def validate_existing_pixel(entries, pixel)
      # set found count to 0
      found = 0

      # begin to iterate through the entries
      entries.each do |request|


        begin
          url_received = URI.unescape(request.request.url)
          # if the request is found
           if(url_received.include?(pixel.step_name)) 
          # if(request.request.url.include?(pixel.step_name))
            # increment found count
            found += 1
            # check the status code if applicable
            if(@custom_settings['status_code'])
              # pass if proper status found
              if(request.response.status == 200 || request.response.status == 302)
                Rails.logger.info "PASS"
              # fail if not
              else
                pixel.errorcode = 103
                pixel.result = 0
                Rails.logger.info "Bad Status Code"
              end
            else
              Rails.logger.info "PASS"
            end
          end
        rescue => e
          # empty catching of bad requests
        end
        # end of entries iteration
      end 
      pixel.save!
      # if it was found
      if(found == 1)
        # mark how many times it was found
        pixel.actual = found
        # pass the test case
        pixel.result = 1
        # save the results
        pixel.save!
      else

        # if pixel wasn't found
        if(found == 0)

          # fail the test
          pixel.result = 0

          # check for status code error code
          if(pixel.errorcode == 103)

            # Pixel not-found where pixel should be + wrong status code
            pixel.errorcode = 105 

          else

            # Pixel not-found where pixel should be
            pixel.errorcode = 104 

          end
        end

        # multiple pixel scenario
        if found > 1
          if @custom_settings['multiple_pixel']
            if(pixel.errorcode == 103)
              pixel.errorcode = 106 # Many pixels found where one pixel should be + wrong status code
              pixel.result = 0 
            else
              pixel.errorcode = 108 # Many pixels found where one pixel should be
              pixel.result = 0
            end
          else
            pixel.result = 1 if pixel.errorcode != 103
          end
        end
        pixel.actual = found
        # save to database
        pixel.save!
      end

      return pixel
    end


    ##
    # Check that pixels marked absent are actually absent
    def validate_nonexisting_pixel(entries, pixel)
      # set found count to 0
      found = 0

      # iterate through each network request in proxy 
      entries.each do |request|
        
        begin
          url_received = URI.unescape(request.request.url)

          # check each network request for the pixel url sample
          # if found, fail the pixel
          if(url_received.include?(pixel.step_name))
          #if(request.request.url.include?(pixel.step_name))
            Rails.logger.info "FAIL"
            found += 1
          end

        rescue => e
          # errors can be raised if any requests are broken
          # most pages have some request which is abnormal or broken, so we catch those here
        end

      end

      # if the nonexistant pixel wasn't found
      if(found == 0)
        # mark this test case as pass, and save value
        pixel.actual = found # should always be 0, but saving actual in case script is wrong
        pixel.result = 1
        pixel.save!
      else
        # mark as failure and record error code and the actual results
        pixel.errorcode = 107 # Pixel found where no pixel should be
        pixel.actual = found
        pixel.result = 0
        pixel.save!
      end
      # return true if found equals 0
      return (found == 0)
    end

def auth_workarounds(url)
          # Wen workaround  
          if(url.include?('wen') && url.include?('.grdev.'))
            Rails.logger.info 'working around Wen auth popups'
            env = url.scan(/.wen.([^.]+)/).first.first
            @browser.driver.browser.get "https://storefront:Grcweb123@www.wen.#{env}.dw.grdev.com"
          # sheercover workaround
            elsif(url.include?('sheercover') && url.include?('.grdev.'))
              Rails.logger.info 'working around sheercover auth popups'
              env = url.scan(/.sheercover.([^.]+)/).first.first
              #@browser.driver.browser.get(@report.url)
              #sheercover.qa.dw.grdev.com/on/demandware.servlet
              @browser.driver.browser.get "https://storefront:Grcweb123@www.sheercover.#{env}.dw.grdev.com"               
              #byebug
          # reclaimbotanical workaround
            elsif(url.include?('reclaimbotanical') && url.include?('.grdev.'))
              Rails.logger.info 'working around reclaimbotanical auth popups'
              env = url.scan(/.reclaimbotanical.([^.]+)/).first.first
              @browser.driver.browser.get "https://storefront:Grcweb123@www.reclaimbotanical.#{env}.dw.grdev.com"
          # principalsecret workaround
            elsif(url.include?('principalsecret') && url.include?('.grdev.'))
              Rails.logger.info 'working around principalsecret auth popups'
              env = url.scan(/.principalsecret.([^.]+)/).first.first
              @browser.driver.browser.get "https://storefront:Grcweb123@www.principalsecret.#{env}.dw.grdev.com"
          # perricone workaround
            elsif(url.include?('perricone') && url.include?('.grdev.'))
              Rails.logger.info 'working around perricone auth popups'
              env = url.scan(/.perricone.([^.]+)/).first.first
              @browser.driver.browser.get "https://storefront:Grcweb123@www.perricone.#{env}.dw.grdev.com" 
          # meaningfulbeauty workaround
            elsif(url.include?('meaningfulbeauty') && url.include?('.grdev.'))
              Rails.logger.info 'working around meaningfulbeauty auth popups'
              env = url.scan(/.meaningfulbeauty.([^.]+)/).first.first
              @browser.driver.browser.get "https://storefront:Grcweb123@www.meaningfulbeauty.#{env}.dw.grdev.com"
          # lumipearl workaround
            elsif(url.include?('lumipearl') && url.include?('.grdev.'))
              Rails.logger.info 'working around lumipearl auth popups'
              env = url.scan(/.lumipearl.([^.]+)/).first.first
              @browser.driver.browser.get "https://storefront:Grcweb123@www.lumipearl.#{env}.dw.grdev.com"
          # tryitnow workaround  
            elsif(url.include?('tryitnow') && url.include?('.grdev.'))
              Rails.logger.info 'working around tryitnow auth popups'
              env = url.scan(/.tryitnow.([^.]+)/).first.first
              @browser.driver.browser.get "https://storefront:Grcweb123@www.tryitnow.#{env}.dw.grdev.com"
          # crepeerase workaround  
            elsif(url.include?('crepeerase') && url.include?('.grdev.'))
              Rails.logger.info 'working around crepeerase auth popups'
              env = url.scan(/.crepeerase.([^.]+)/).first.first
              @browser.driver.browser.get "https://storefront:Grcweb123@www.crepeerase.#{env}.dw.grdev.com"
          # beautybioscience workaround  
            elsif(url.include?('beautybioscience') && url.include?('.grdev.'))
              Rails.logger.info 'working around beautybioscience auth popups'
              env = url.scan(/.beautybioscience.([^.]+)/).first.first
              @browser.driver.browser.get "https://storefront:Grcweb123@www.beautybioscience.#{env}.dw.grdev.com"
          end
          # clear the proxy for network collection and proceed to testrun
            @proxy.new_har "wen"
    end
    ##
    # prevent login popups on proactiv websites and meaningfulbeauty on QA
    # def auth_workarounds(url)
    #   # proactiv workarounds
    #   if(url.downcase.include?('proactiv') && @report.url.include?('.grdev.'))
    #     Rails.logger.info 'working around auth popups'
    #     env = @report.url.scan(/.proactiv.([^.]+)/).first.first
    #     @browser.driver.browser.get "https://storefront:Grcweb123@proactiv.#{env}.dw.grdev.com"       
    #     @browser.driver.browser.get "https://storefront:Grcweb123@proactiv.#{env}.dw.grdev.com/on/demandware.store/Sites-Proactiv-Site/default/RedirectURL-Hostname"
    #     @browser.driver.browser.get "https://storefront:Grcweb123@original.proactiv.#{env}.dw.grdev.com"
    #     @browser.driver.browser.get "https://storefront:Grcweb123@mypa.proactiv.#{env}.dw.grdev.com"
    #   end
    #   if(url.include?('crepeerase') && @report.url.include?('.grdev.'))
    #     env = @report.url.scan(/.crepeerase.([^.]+)/).first.first
    #     @browser.driver.browser.get "https://storefront:Grcweb123@www.crepeerase.#{env}.dw2.grdev.com"
    #   end

    #   # meaningfulbeauty workarounds
    #   if(url.include?('meaningfulbeauty.stg01.qa.')) # does this URL make sense?
    #     Rails.logger.info 'working around auth popups'
    #     @browser.driver.browser.get "https://storefront:Grcweb123@catalog-meaningfulbeauty.stg01.dw.grdev.com"
    #   end

    #   # clear the proxy for network collection and proceed to testrun
    #   @proxy.new_har "proactiv"
    # end


    ##
    # scrapes the confirmation number from confirmation page
    # @return any confirmation number found, as soon as one is found
    # def get_confirmation_number()
      
    #   # set the value to a blank string incase nothing is found
    #   confirmation_num = ''

    #   # list of locators for confirmation numbers, based on the same locators used for other tests
    #   confirmation_locators = Locator.where(brand: 'All', step: 'ConfNum', offer: 'All')

    #   # iterate through each locator
    #   confirmation_locators.each do |conf_num_locator|
    #     begin
    #       # in order to search for any matches, and pull that text and match the text to a string pattern for known confirmation numbers
    #       confirmation_num = @browser.find(conf_num_locator.css).text().match(/:\s*([^\s\/\:]{6,})/) if(@browser.first(conf_num_locator.css))
    #     rescue => e
    #       # if issue happens, ignore and go to next locator, total failure will be captured if all locators fail.
    #       # We assume that a locator failing is probable, as locators not present or used correctly would probably raise an error here
    #     end
    #   end
    #   begin
    #     # return any values captured
    #     return confirmation_num.captures.first
    #   rescue => e
    #     # if no values found, return empty string to the test
    #     return ''
    #   end
    # end

    def get_confirmation_number()
      begin
        @browser.find(:xpath, './/span[@id="orderConfirmNum"]').text
      rescue => e

      end
    end


    ##
    # get all locators needed for testing from the database
    # @return Locator active record relation containing all locators used for this test
    def locators()
      Locator.where(brand: 'all', offer: 'orderplacementlocators')
    end


    ##
    # uses data from database on selectors in use on websites to execute actions needed to place a test order
    def place_order()
puts "pixel placing orders"
      # query database for locators
      locat = locators()

      # Rails.logger.info "clicking order now"

      # locat.where(step: "order_now").each do |locator|
      #   begin
      #     @browser.first(:css, locator.css).click()
      #   rescue => e

      #   end
      # end

      # sleep(3)

      # locat.where(step: "order_now").each do |locator|
      #   begin
      #     @browser.first(:css, locator.css).click()
      #   rescue => e

      #   end
      # end

      # sleep(3)

      # locat.where(step: "order_now").each do |locator|
      #   catch_simple do
      #     @browser.first(:css, locator.css).click()
      #   end
      # end
      # # workaround for if the 
      # catch_simple do
      #   if(@browser.current_url.include?('reclaimbotanical'))
      #     sleep(5)
      #     @browser.find(:css, 'a.closebtn').click()
      #   end
      # end

      Rails.logger.info "filling out email"
      locat.where(step: "emailfield").each do |locator|
        catch_simple do
          # @browser.fill_in(locator.css, :with => (@email))
          @browser.fill_in(locator.css, :with => 'irrisonnorr-4965@yopmail.com')
        end

      end

      locat.where(step: "fullphone").each do |locator|
        catch_simple do
          @browser.fill_in(locator.css, :with => '9999999999')
        end
      end

      locat.where(step: "phone1").each do |locator|
        catch_simple do
          @browser.fill_in(locator.css, :with => '999')
        end
      end

      locat.where(step: "phone2").each do |locator|
        catch_simple do
          @browser.fill_in(locator.css, :with => '999')
        end
      end

      locat.where(step: "phone3").each do |locator|
        catch_simple do
          @browser.fill_in(locator.css, :with => '9999')
        end
      end


      Rails.logger.info "filling out billing"

      locat.where(step: "firstname").each do |locator|
        catch_simple do
          @browser.fill_in(locator.css, :with => 'Digital')
        end
      end

      locat.where(step: "lastname").each do |locator|
        catch_simple do
          @browser.fill_in(locator.css, :with => 'Automation')
        end
      end

      locat.where(step: "address1").each do |locator|
        catch_simple do
          @browser.fill_in(locator.css, :with => '123 QATest Street')
        end
      end
      
      # twice to avoid problems with location request permission removing focus
      locat.where(step: "address1").each do |locator|
        catch_simple do
          @browser.fill_in(locator.css, :with => '123 QATest Street')
        end
      end

      locat.where(step: "city").each do |locator|
        catch_simple do
          @browser.fill_in(locator.css, :with => 'Anywhere')
        end
      end

      locat.where(step: "zip").each do |locator|
        catch_simple do
          @browser.fill_in(locator.css, :with => '90405')
        end
      end

      locat.where(step: "state").each do |locator|
        catch_simple do
          # @browser.find(:css, locator.css).select('CA')
          @browser.find_field(locator.css).find("option[value='CA']").select_option
        end
      end

      locat.where(step: "state").each do |locator|
        catch_simple do
          # @browser.find(:css, locator.css).select('California')
          @browser.find_field(locator.css).find("option[value='California']").select_option
        end
      end

      catch_simple do
        if(@browser.current_url.include?('reclaimbotanical'))
          sleep(5)
          catch_simple do
            @browser.find(:css, 'a.closebtn').click()
          end
          locat.where(step: "contyourorder").each do |locator|
            catch_simple do
              if(@browser.first(:css, locator.css))
                @proxy.new_har "wen_conf"
              end
              @browser.first(:css, locator.css).click()
            end
          end
        end
      end

      Rails.logger.info "filling out credit card"

      locat.where(step: "ccnumber").each do |locator|
        catch_simple do
          @browser.fill_in(locator.css, :with => '4111111111111111')
        end
      end

      locat.where(step: "ccmonth").each do |locator|
        catch_simple do
          # @browser.find(:css, locator.css).select('07')
          @browser.find_field(locator.css).find("option[value='10']").select_option
        end
      end

      locat.where(step: "ccmonth").each do |locator|
        catch_simple do
          # @browser.find(:css, locator.css).select('July')
          @browser.find_field(locator.css).find("option[value='October']").select_option
        end
      end

      locat.where(step: "paymentmethod").each do |locator|
        catch_simple do
          @browser.find(:css, locator.css).select('Visa')
        end
      end

      locat.where(step: "ccyear").each do |locator|
        catch_simple do
          # @browser.find(:css, locator.css).select('2019')
          @browser.find_field(locator.css).find("option[value='2019']").select_option
        end
      end

      locat.where(step: "agreecheck").each do |locator|
        catch_simple do
          # @browser.find(:css, locator.css).click()
          @browser.find_field(locator.css).click()
        end
        catch_simple do
            @browser.first(:css, locator.css, :visible => false).set(true)
          end
      end

      Rails.logger.info "Completing order"

      locat.where(step: "contyourorder").each do |locator|
        catch_simple do
          if(@browser.first(:css, locator.css))
            @proxy.new_har "wen_conf"
          end
          @browser.find(:css, locator.css).click()
        end
      end

      

      # catch_simple do
      #   sleep(3)
      #   locat.where(step: "contyourorder").each do |locator|
      #     catch_simple do
      #       if(@browser.first(:css, locator.css))
      #         @proxy.new_har "wen_conf"
      #       end
      #       @browser.first(:css, locator.css).click()
      #     end
      #   end
      #   locat.where(step: "contyourorder").each do |locator|
      #     catch_simple do
      #       if(@browser.first(:css, locator.css))
      #         @proxy.new_har "wen_conf"
      #       end
      #       @browser.first(:css, locator.css).click()
      #     end
      #   end
      #   sleep(3)
      #   locat.where(step: "contyourorder").each do |locator|
      #     catch_simple do
      #       if(@browser.first(:css, locator.css))
      #         @proxy.new_har "wen_conf"
      #       end
      #       @browser.first(:css, locator.css).click()
      #     end
      #   end
      #   locat.where(step: "contyourorder").each do |locator|
      #     catch_simple do
      #       if(@browser.first(:css, locator.css))
      #         @proxy.new_har "wen_conf"
      #       end
      #       @browser.first(:css, locator.css).click()
      #     end
      #   end
      # end

      # catch_simple do
      #   sleep(3)
      #   locat.where(step: "contyourorder").each do |locator|
      #     catch_simple do
      #       if(@browser.first(:css, locator.css))
      #         @proxy.new_har "wen_conf"
      #       end
      #       @browser.first(:css, locator.css).click()
      #     end
      #   end
      #   locat.where(step: "contyourorder").each do |locator|
      #     catch_simple do
      #       if(@browser.first(:css, locator.css))
      #         @proxy.new_har "wen_conf"
      #       end
      #       @browser.first(:css, locator.css).click()
      #     end
      #   end
      #   sleep(3)
      #   locat.where(step: "contyourorder").each do |locator|
      #     catch_simple do
      #       if(@browser.first(:css, locator.css))
      #         @proxy.new_har "wen_conf"
      #       end
      #       @browser.first(:css, locator.css).click()
      #     end
      #   end
      #   (0..3).each do 
      #     catch_simple do
      #       @browser.all('#contYourOrder').last.click()
      #     end
      #   end
      #   locat.where(step: "contyourorder").each do |locator|
      #     catch_simple do
      #       if(@browser.first(:css, locator.css))
      #         @proxy.new_har "wen_conf"
      #       end
      #       @browser.first(:css, locator.css).click()
      #     end
      #   end
      # end
    end
  end
end