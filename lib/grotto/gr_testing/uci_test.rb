module GRTesting
    
    class UciTest < WebTest

        # @!attribute [rw] browser 
        #   A {http://www.rubydoc.info/github/jnicklas/capybara/Capybara/Session Capybara::Session}
        #   @return [Capybara::Session] 

        attr_accessor :browser

        attr_accessor :browser_string

        attr_accessor :os

        # @!attribute [rw] testtype 

        attr_accessor :testtype

        attr_accessor :platform

        attr_accessor :custom_settings

        attr_reader :retries

        attr_reader :remote_url

        attr_reader :offercode

        attr_reader :order_id

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
        #   Hash containing all the pixels that should be checked, and the values for each is whether or not the pixel should appear or not
        #   @return [Hash] The hash of all pixels and their values
        attr_accessor :pixelhash

        attr_accessor :last_page_reached

        def initialize(title: 'Testcase', browser: 'ie11', validations: nil, id: nil)
            # call the test case super method
            super(title: title, id: id, browser: browser)
            @pixelhash            = pixelhash
            @report.driver        = @browsertype
        end

        def before
            # executes before anything else
            super()
            # workarounds for http basic auth login popups
            #auth_workarounds(@url)
            @browser.driver.browser.get(@url)
            
            @remote_url  = GridUtilities.get_session_ip(session: @browser)
            campaign_data = {}       
            campaign_data.merge!({'ConfEmailOverride' => @email})
            @page = T5::BasePage.new(campaign_data)
            @page.browser = @browser
            @report.title = @url
            @report.uci_report      = GRReporting::UCIReport.new()
        end

        def execute
            super()
            if(custom_settings['retries'])
              timeout_counter = custom_settings['retries'].to_i
            else
              timeout_counter = 0
            end

            begin
              @page.check_if_page_ready
              # Gather UCI from landing
              @report.uci_report.uci_mp = @page.uci

              # Check for common page failures
              check_for_page_errors()
              sleep(3)

              # loop through order page navigation method twice
              go_to_orderpage()
              @page.check_if_page_ready
              # go_to_orderpage()
              # @page.check_if_page_ready

              
              
              # Navigate to order page
              
              @report.uci_report.uci_op = @page.uci
              puts @report.uci_report.uci_op
              @report.grcid = @page.grcid
              puts @report.grcid
              @offercode = @page.offercode()
              puts @offercode
              # binding.pry if(@page.offercode().nil?)
              puts "check header and footer"
              check_header_and_footer()

              # Navigate to confirmation page
              @page.place_order(@email)

              @page.check_if_page_ready

              @order_id =  @page.get_confirmation_number()

              @report.uci_report.uci_cp = @page.uci
            rescue => e
              
            if(timeout_counter > 0)
              timeout_counter -= 1
              # clean up
              after()

              # setup new run
              before()

              # retry test case
              retry
            end
            raise e
          end
        end

        def after
            begin
              begin
                @last_page_reached = @page.page_name
                @browser_string = @page.browser_name
                @os    = @page.os_name
              rescue => e

              end
              @browser.save_screenshot("public/debug/test_run/#{@id}.png")
            rescue => e

            end
            super()
        end

        def upload_report
            run = TestRun.find(@id)
            # get record from test run
           
            # Update record for errors
            begin
             if(@errors.first)
                error_obj = ErrorMessage.new()
                error_obj.class_name = @errors.first.class.to_s
                error_obj.message = @errors.first.message
                error_obj.backtrace = @errors.first.backtrace.join("\n")
                error_obj.test_run_id = run.id
                error_obj.save!

                run.result = 0
                run.Notes = @errors.first.message
             end
            rescue => e

            end

            # get the validations for this test run
            validations = run.test_steps

            # Adding data from test run
            run.offercode   = @offercode
            run.campaign    = @report.grcid
            run.runtime     = @report.runtime
            run.platform    = @os
            run.browser     = @browser_string
            run.order_id    = @order_id
            data_collected = {}
            
            if(validations.where(step_name: "Landing UCI").empty? == false)
              # Update record for UCI for landing
              uci_mp = validations.where(step_name: "Landing UCI").first
              uci_mp.actual = @report.uci_report.uci_mp
              data_collected["Landing UCI"] = uci_mp.actual = @report.uci_report.uci_mp
              if(uci_mp.actual == uci_mp.expected)
                  uci_mp.result = 1
              else
                  uci_mp.result = 0
              end
              uci_mp.save!
            end
            if(validations.where(step_name: "SAS UCI").empty? == false)
              # Update record for UCI for SAS
              uci_op = validations.where(step_name: "SAS UCI").first
              uci_op.actual = @report.uci_report.uci_op
              data_collected["SAS UCI"] = uci_mp.actual = @report.uci_report.uci_op
              if(uci_op.actual == uci_op.expected)
                  uci_op.result = 1
              else
                  uci_op.result = 0
              end
              uci_op.save!
            end

            if(validations.where(step_name: "Confirmation UCI").empty? == false)
              # Update record for UCI for Confirmation
              uci_cp = validations.where(step_name: "Confirmation UCI").first
              uci_cp.actual = @report.uci_report.uci_cp
              data_collected["Confirmation UCI"] = uci_mp.actual = @report.uci_report.uci_cp

              if(uci_cp.actual == uci_cp.expected)
                  uci_cp.result = 1
              else
                  uci_cp.result = 0
              end
              uci_cp.save!
            end

            if(validations.where(step_name: "Campaign").empty? == false)
              # Update record for Campaign
              offer_step = validations.where(step_name: "Campaign").first
              offer_step.actual = run.campaign
              if(offer_step.actual == offer_step.expected)
                  offer_step.result = 1
              else
                  offer_step.result = 0
              end
              offer_step.save!
            end
            
            # only run this if offercode validation was generated by test case
            if(validations.where(step_name: "Offercode").empty? == false)
              # Update record for Offercode
              offer_step = validations.where(step_name: "Offercode").first
              offer_step.actual = run.offercode
              if(offer_step.actual == offer_step.expected)
                  offer_step.result = 1
              else
                  offer_step.result = 0
              end
              offer_step.save!
            end

            # Update record for Confirmation Number
            conf_num = validations.where(step_name: "Confirmation Number").first
            conf_num.actual = (@order_id != 'N/A' && @order_id != nil) ? 'Exists' : 'Does not exist'
            if(conf_num.actual == conf_num.expected)
                conf_num.result = 1
            else
                conf_num.result = 0
            end
            conf_num.save!

            # Check for any errors
            if(validations.where(result: 0).empty?)
                run.result = 1
            else
                run.result = 0
            end



            run.custom_data = data_collected
            run.status = "Complete"
            run.save!

        end

        def homepage_popovers
          #@page.js_exec "$('.ui-dialog-titlebar-close').click()"
          @page.js_exec("$('.tv0ffer-popup').hide()")
          #@page.js_exec("$('.special-offers-popup').hide()")
          @page.js_exec("$('.ui-widget-overlay').hide()") 
          @page.js_exec("$('#notify').hide()")         
          #@page.js_exec "$('.popover__later.popover__link.js-later').click()" #ssankara - To close the pop-over on DDC content pages
        end

        def move_to_cart()
          @browser.first(:css, '.product-image a.thumb-link').click()
          @browser.find(:css, '#add-to-cart').click()
          sleep(2)
          @browser.find(:css, 'a[title="Checkout"]').click()
        end

        def go_to_orderpage()
          puts "going to order page"
          if((@url.to_s.downcase.include? 'marajo') && (@browser.has_selector?(:xpath, './/ul/li[@class="products "]/a')))
            begin
              @browser.find(:xpath, './/ul/li[@class="products "]/a').click
              move_to_cart()
            rescue => e

            end
          elsif((@url.to_s.downcase.include? 'smileactives') && (@browser.has_selector?(:xpath, './/ul/li[@data-menu="ShopAll"]/a')))
            begin
              @browser.find(:xpath, './/ul/li[@data-menu="ShopAll"]/a').click
              move_to_cart()
            rescue => e

            end
          else
            begin
              puts "Going to orderpage"
              locat = Locator.where(brand: 'all', offer: 'orderplacementlocators')
              if(@browser.first('.special-offers-popup') || @browser.first('.popover') || @browser.first('.tv0ffer-popup') || @browser.first('#notify'))
                homepage_popovers
                sleep(2)
              end
              Rails.logger.info "clicking order now"
              puts "clicking order now"
              locat.where(step: "order_now").each do |locator|
                begin
                  @browser.first(:css, locator.css).click()
                rescue => e

                end
              end
              puts "done clicking order now"
              sleep(3)
              if(@browser.first('.special-offers-popup') || @browser.first('.popover') || @browser.first('.tv0ffer-popup'))
                homepage_popovers
                sleep(2)
              end

              locat.where(step: "order_now").each do |locator|
                begin
                  @browser.first(:css, locator.css).click()
                rescue => e

                end
              end

              sleep(3)

              locat.where(step: "order_now").each do |locator|
                begin
                  @browser.first(:css, locator.css).click()
                rescue => e

                end
              end
              if(@browser.has_selector?(:xpath, './/a[@class="buttons-next next-page section-cart"]'))
                begin
                  @browser.find(:xpath, './/a[@class="buttons-next next-page section-cart"]').click
                rescue => e

                end
              end
            rescue => e

            end
          end
        end

        # ##
        # # uses all known buttons on the way to order page to get to order page
        # def go_to_orderpage()
        #     locat = Locator.where(brand: 'all', offer: 'orderplacementlocators')
        #     if(@browser.first('.special-offers-popup') || @browser.first('.popover') || @browser.first('.tv0ffer-popup') || @browser.first('#notify'))
        #       homepage_popovers
        #       sleep(2)
        #     end
        #     Rails.logger.info "clicking order now"

        #     locat.where(step: "order_now").each do |locator|
        #       begin
        #         @browser.first(:css, locator.css).click()
        #       rescue => e

        #       end
        #     end

        #     sleep(3)
        #     if(@browser.first('.special-offers-popup') || @browser.first('.popover') || @browser.first('.tv0ffer-popup'))
        #       homepage_popovers
        #       sleep(2)
        #     end

        #     locat.where(step: "order_now").each do |locator|
        #       begin
        #         @browser.first(:css, locator.css).click()
        #       rescue => e

        #       end
        #     end

        #     sleep(3)

        #     locat.where(step: "order_now").each do |locator|
        #       begin
        #         @browser.first(:css, locator.css).click()
        #       rescue => e

        #       end
        #     end
        # end

        ##
        # Grabs locator data for this validation and then runs the header and then the footer checks
        def check_header_and_footer()
          puts "checking header and footer"
          locators = Locator.where(brand: 'all', step: 'vanityuci')
          header_check(locators)
          footer_check(locators)
          return true
        end

        ##
        # checks for all known header selectors
        def header_check(locators)
          puts "checking header"
          sleep(4) # do we need this?
          passing = false
          locators.where(offer: 'header').each do |locator|
            passing = true if browser.first(locator.css)
          end
          raise "Could Not Find Header" if passing == false
        end

        ##
        # checks for all known footer selectors
        def footer_check(locators)
          puts "checking footer"
          passing = false
          locators.where(offer: 'footer').each do |locator|
            passing = true if browser.first(locator.css)
          end
          raise "Could Not Find Footer" if passing == false
        end

        ##
        # prevent login popups on proactiv websites and meaningfulbeauty on QA
        # def auth_workarounds(url)
        #   # proactiv workarounds
        #   if(url.downcase.include?('proactiv') && url.include?('.grdev.'))
        #     Rails.logger.info 'working around auth popups'
        #     env = url.scan(/.proactiv.([^.]+)/).first.first
        #     @browser.driver.browser.get "https://storefront:Grcweb123@proactiv.#{env}.dw.grdev.com"       
        #     @browser.driver.browser.get "https://storefront:Grcweb123@proactiv.#{env}.dw.grdev.com/on/demandware.store/Sites-Proactiv-Site/default/RedirectURL-Hostname"
        #     @browser.driver.browser.get "https://storefront:Grcweb123@original.proactiv.#{env}.dw.grdev.com"
        #     @browser.driver.browser.get "https://storefront:Grcweb123@mypa.proactiv.#{env}.dw.grdev.com"
        #   end

        #   if(url.include?('crepeerase') && url.include?('.grdev.'))
        #     env = url.scan(/.crepeerase.([^.]+)/).first.first
        #     @browser.driver.browser.get "https://storefront:Grcweb123@www.crepeerase.#{env}.dw2.grdev.com"
        #   end

        #   # meaningfulbeauty workarounds
        #   if(url.include?('meaningfulbeauty.stg01.qa.')) # does this URL make sense?
        #     Rails.logger.info 'working around auth popups'
        #     @browser.driver.browser.get "https://storefront:Grcweb123@catalog-meaningfulbeauty.stg01.dw.grdev.com"
        #   end

        # end

        ##
        # Checks for major page issues, raising them if they exist
        def check_for_page_errors()
            # Check for common page failures
            begin
              # Promo code scenario
              if(browser.first('#deluxepromo') || browser.first('#threesteppromo'))
                raise "Promo Code needed (Auth)"
              end

              # Empty cart scenario
              if(browser.first('.cartempty'))
                if(browser.first('.cartempty').text == "There are no items in your cart")
                  raise "!!!Empty Cart on Order Page"
                end
              end

              # Page doesn't exist scenario
              if(browser.first('.notfound'))
                error_message_element = browser.first(:css, '.notfound')
                error_text = error_message_element.text()
                if(error_text.include? 'we cannot locate the page you requested')
                  raise "Page doesn't Exist!!"
                end
              end
      
              # Page doesn't exist scenario
              if(browser.first('.mainWide'))
                error_message_element = browser.first(:css, '.mainWide')
                error_text = error_message_element.text()
                if(error_text.include? 'we cannot locate the page you requested')
                  raise "Page doesn't Exist!!"
                end
              end
      
              # Login page, non-compatible site scenario
              # if(browser.current_url.include? "proactiv.com/login")
              #   raise "!!!Login Page!!! - No testing"
              # end

              # Page Load Failure checks
              if(browser.first('body:empty'))
                raise "!!!Empty body response"
              end
              
              # Check for blank page issue
              if(browser.first('body'))
                if(browser.first('body').text() == "")
                  raise "!!! Blank Page response"
                end
              end

              # check for 500 response
              if(browser.title == "500 Internal Error.")
                raise "!!! 500 Internal Error"
              end
            rescue => e
              raise e
            end
        end
    end
end