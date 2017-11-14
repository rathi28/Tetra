require 'open-uri'
require "net/https"
require "uri"

module GRTesting
    
    class SeoTest < WebTest

        # @!attribute [rw] browser 
        #   A {http://www.rubydoc.info/github/jnicklas/capybara/Capybara/Session Capybara::Session}
        #   @return [Capybara::Session] 

        attr_accessor :browser

        attr_accessor :browser_string

        attr_accessor :os

        # @!attribute [rw] testtype 

        attr_accessor :testtype

        attr_accessor :platform

        attr_accessor :entries

        attr_accessor :custom_settings

        attr_reader :retries

        attr_reader :remote_url

        attr_reader :offercode

        attr_reader :order_id

        attr_accessor :seo_results
        attr_accessor :robots_file
        attr_accessor :sitemap_file

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
          puts "seo initialise"
            # call the test case super method
            super(title: title, id: id, browser: browser)
            @pixelhash            = pixelhash
            @report.driver        = @browsertype
            @seo_results = {}
        end

        def before
          puts "seo before"
            # executes before anything else
            super()
            puts "gonna quit"
            @browser.driver.quit
            # workarounds for http basic auth login popups
            @proxy_ip = Grid_Processes.where('role = ?', "proxy").first.ip
            puts @proxy_ip
            @proxy = BrowserMob::Proxy::Client.from("http://#{@proxy_ip}:9090")
            puts "printing platform"
            puts @platform
            case @platform.downcase
            when "mobile"
              @browser = BrowserFactory.grid_browser_mob_firefox_iphone(@proxy)
            when "tablet"
              @browser = BrowserFactory.grid_browser_mob_firefox_ipad(@proxy)
            else
              @browser = BrowserFactory.grid_browser_mob_firefox(@proxy)
            end
            @browser.title
            @proxy.new_har "seotest"            
            # workarounds for https basic login authentication popups
            auth_workarounds(@url)
            @browser.driver.browser.get(@url)
            @entries = @proxy.har.entries

            @remote_url  = GridUtilities.get_session_ip(session: @browser)
            puts "remote url"
            puts @remote_url
            campaign_data = {}      
            campaign_data.merge!({'ConfEmailOverride' => @email})
            @page = T5::HomePage.new(campaign_data)
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

              ## SEO Files validations ##

              ## Robots.txt flag
              @robots_file = [false, nil]

              ## sitemap.xml falg
              @sitemap_file = {}

              ## Get URL domain
              url_host = @url.match(/\/\/([^\/]+)/).captures().first

              if custom_settings['robottxtseocheck'].nil? == false
                ## Get SEOFile object
                file_obj = SeoFile.where('filename = ?', "robots.txt").where("domain like ?", url_host).first()
                if(!file_obj.nil?)
                  # check robots.txt
                  @robots_file = check_seo_file(file_obj, url_host)
                end
              end

              if custom_settings['sitemapxmlseocheck'].nil? == false
                file_objs = SeoFile.where('filename = ?', "sitemap.xml").where("domain like ?", url_host)
                if(file_objs)
                  @sitemap_file = {}
                end
                file_objs.each do |file_obj|
                  # check sitemap.xml
                  @sitemap_file[file_obj.targeturl.split(//).last(50).join()] = [false, nil]
                  @sitemap_file[file_obj.targeturl.split(//).last(50).join()] = check_seo_file(file_obj, url_host)
                end
              end

              @page.check_if_page_ready
              # Gather UCI from landing
              @report.uci_report.uci_mp = @page.uci

              # Check for common page failures
              check_for_page_errors()
              @seo_results["redirectcode"] = {}
              @seo_results["redirectcode"] = get_redirect_code(@browser.current_url)

              current_page = page_name.downcase if(page_name.nil? == false)
              correct_page = false

              PageIdentifier.where(page: 'Home').each do |ident|
                if(current_page.include? ident.value) 
                  correct_page = true
                end
              end

              
              if(correct_page)
                if(custom_settings['homepageseocheck'].nil? == false)
                  @seo_results["homepageseocheck"] = {}
                  @seo_results["homepageseocheck"]["tags"] = find_tags('Home')
                end
              end

              sleep(3)
              
              @orderbtns = Locator.where(:step => 'Ordernow')
              if(@browser.first('.special-offers-popup') || @browser.first('.popover') || @browser.first('.tv0ffer-popup') || @browser.first('#notify'))
                homepage_popovers
                @page.homepage_popovers
                sleep(2)
              end

              # loop through order page navigation method twice
              @page.click_all_orderbtns(@orderbtns)
              @page.check_if_page_ready
              if(@browser.first('.special-offers-popup') || @browser.first('.popover') || @browser.first('.tv0ffer-popup') || @browser.first('#notify'))
                homepage_popovers
                @page.homepage_popovers
                sleep(2)
              end

              @page.click_all_orderbtns(@orderbtns)
              @page.check_if_page_ready
              puts "SAS"


              current_page = page_name.downcase if(page_name.nil? == false)
              correct_page = false
              
              PageIdentifier.where(page: 'SAS').each do |ident|
                if(current_page.include? ident.value) 
                  correct_page = true
                end
              end
              
              
              
              if(correct_page)
                if(custom_settings['saspageseocheck'].nil? == false)
                  @seo_results["saspageseocheck"] = {}
                  @seo_results["saspageseocheck"]["tags"] = find_tags('SAS')
                end
              end

              # Navigate to order page
              go_to_orderpage()
              @page.check_if_page_ready
              go_to_orderpage()
              @page.check_if_page_ready
              puts "Cart"

              @report.uci_report.uci_op = @page.uci

              @report.grcid = @page.grcid

              @offercode = @page.offercode()
              # binding.pry if(@page.offercode().nil?)
              check_header_and_footer()
              

              current_page = page_name.downcase if(page_name.nil? == false)
              correct_page = false
              PageIdentifier.where(page: 'Cart').each do |ident|
                if(current_page.include? ident.value) 
                  correct_page = true
                end
              end
              
              if(correct_page)
                if(custom_settings['cartpageseocheck'].nil? == false)
                  @seo_results["cartpageseocheck"] = {}
                  @seo_results["cartpageseocheck"]["tags"] = find_tags('Cart')
                  # @seo_results["cartpageseocheck"]["redirectcode"] = get_redirect_code(@browser.current_url)
                end
              else
                raise  "Cart Page not reached"
              end

              if(custom_settings['confirmationseocheck'].nil? == true)
                return true
              end

              # Navigate to confirmation page
              # @page.place_order(@email)

              @page.check_if_page_ready
              

              current_page = page_name.downcase if(page_name.nil? == false)
              correct_page = false
              PageIdentifier.where(page: 'Confirmation').each do |ident|
                if(current_page.include? ident.value) 
                  correct_page = true
                end
              end

              if(correct_page)

                if(custom_settings['confirmationseocheck'].nil? == false)
                  @seo_results["confirmationseocheck"] = {}
                  @seo_results["confirmationseocheck"]["tags"] = find_tags('Confirmation')
                  # @seo_results["confirmationseocheck"]["redirectcode"] = get_redirect_code(@browser.current_url)
                end
              else
                raise  "Confirmation Page not reached"
              end

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
            begin
              @browser.driver.quit
            rescue => e

            end

            begin
              @proxy.close
            rescue => e

            end
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
            data_collected["Email Used"] = @email
            
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

            # only run this if redirect validation was generated by test case
            if(validations.where(step_name: "Redirect Status Code").empty? == false)
              # Update record for Offercode
              offer_step = validations.where(step_name: "Redirect Status Code").first
              if(@seo_results["redirectcode"][:result])
                offer_step.actual = @seo_results["redirectcode"][:codes]
                offer_step.result = 1
              else
                offer_step.actual = @seo_results["redirectcode"][:codes]
                offer_step.result = 0
              end
              offer_step.save!
            end

            # only run this if robots.txt validation was generated by test case
            if(validations.where(step_name: "robots.txt").empty? == false)
              # Update record for Offercode
              offer_step = validations.where(step_name: "robots.txt").first
              
              # save file contents
              begin
                File.open(Rails.root.join('public', "debug/seo/#{@id}_actual_robots.txt"), "w") { |file|  
                  file.write @robots_file[1].gsub("\r","")
                  file.close
                } 
              rescue => e
                e.display
              end

              offer_step.actual = "<a href='/debug/seo/#{@id}_actual_robots.txt' target='_blank'>Link to actual robots.txt</a>"
              offer_step.actual = @robots_file[2] if @robots_file[2]
              offer_step.result = @robots_file[0] ? 1 : 0
              offer_step.save!
            end
            url_host = @url.match(/\/\/([^\/]+)/).captures().first
            file_objs = SeoFile.where('filename = ?', "sitemap.xml").where("domain like ?", url_host)
            file_objs.each do |file_obj|
              # only run this if sitemap.xml validation was generated by test case
              if(validations.where(step_name: file_obj.targeturl.split(//).last(50).join()).empty? == false)
                # Update record for Offercode
                offer_step = validations.where(step_name: file_obj.targeturl.split(//).last(50).join()).first
                
                # save file contents
                begin
                  File.open(Rails.root.join('public', "debug/seo/#{@id}_#{offer_step.id}_actual_sitemap.xml"), "w") { |file|  
                    file.write @sitemap_file[file_obj.targeturl.split(//).last(50).join()][1].gsub("\r","")
                    file.close
                  } 
                rescue => e
                  e.display
                end

                offer_step.actual = "<a href='/debug/seo/#{@id}_#{offer_step.id}_actual_sitemap.xml' target='_blank'>Link to actual sitemap.xml</a>"
                offer_step.actual = @sitemap_file[file_obj.targeturl.split(//).last(50).join()][2].gsub("\r","") if @sitemap_file[file_obj.targeturl.split(//).last(50).join()][2]
                offer_step.result = @sitemap_file[file_obj.targeturl.split(//).last(50).join()][0] ? 1 : 0
                offer_step.save!
              end
            end

            # only run this if redirect validation was generated by test case
            if(validations.where(step_name: "Homepage SEO Canonical Tag").empty? == false && @seo_results["homepageseocheck"].nil? == false)
              # Update record for Offercode
              offer_step = validations.where(step_name: "Homepage SEO Canonical Tag").first
              offer_step.actual = @seo_results["homepageseocheck"]["tags"][:canonical][:actual]
              offer_step.expected = @seo_results["homepageseocheck"]["tags"][:canonical][:expected]
              offer_step.result = @seo_results["homepageseocheck"]["tags"][:canonical][:result] ? 1 : 0
              offer_step.save!
            end

            # only run this if redirect validation was generated by test case
            if(validations.where(step_name: "SAS SEO Canonical Tag").empty? == false && @seo_results["saspageseocheck"].nil? == false)
              # Update record for Offercode
              offer_step = validations.where(step_name: "SAS SEO Canonical Tag").first
              offer_step.actual = @seo_results["saspageseocheck"]["tags"][:canonical][:actual]
              offer_step.expected = @seo_results["saspageseocheck"]["tags"][:canonical][:expected]
              offer_step.result = @seo_results["saspageseocheck"]["tags"][:canonical][:result] ? 1 : 0
              offer_step.save!
            end

            # only run this if redirect validation was generated by test case
            if(validations.where(step_name: "Cart SEO Canonical Tag").empty? == false && @seo_results["cartpageseocheck"].nil? == false)
              # Update record for Offercode
              offer_step = validations.where(step_name: "Cart SEO Canonical Tag").first
              offer_step.actual = @seo_results["cartpageseocheck"]["tags"][:canonical][:actual]
              offer_step.expected = @seo_results["cartpageseocheck"]["tags"][:canonical][:expected]
              offer_step.result = @seo_results["cartpageseocheck"]["tags"][:canonical][:result] ? 1 : 0
              offer_step.save!
            end

            # only run this if redirect validation was generated by test case
            if(validations.where(step_name: "Confirmation SEO Canonical Tag").empty? == false && @seo_results["confirmationseocheck"].nil? == false)
              # Update record for Offercode
              offer_step = validations.where(step_name: "Confirmation SEO Canonical Tag").first
              offer_step.actual = @seo_results["confirmationseocheck"]["tags"][:canonical][:actual]
              offer_step.expected = @seo_results["confirmationseocheck"]["tags"][:canonical][:expected]
              offer_step.result = @seo_results["confirmationseocheck"]["tags"][:canonical][:result] ? 1 : 0
              offer_step.save!
            end

            # only run this if redirect validation was generated by test case
            if(validations.where(step_name: "Homepage SEO Robots Tag").empty? == false && @seo_results["homepageseocheck"].nil? == false)
              # Update record for Robots
              offer_step = validations.where(step_name: "Homepage SEO Robots Tag").first
              offer_step.actual = @seo_results["homepageseocheck"]["tags"][:robots][:actual]
              offer_step.expected = @seo_results["homepageseocheck"]["tags"][:robots][:expected]
              offer_step.result = @seo_results["homepageseocheck"]["tags"][:robots][:result] ? 1 : 0
              offer_step.save!
            end

            # only run this if redirect validation was generated by test case
            if(validations.where(step_name: "SAS SEO Robots Tag").empty? == false && @seo_results["saspageseocheck"].nil? == false)
              # Update record for Robots
              offer_step = validations.where(step_name: "SAS SEO Robots Tag").first
              offer_step.actual = @seo_results["saspageseocheck"]["tags"][:robots][:actual]
              offer_step.expected = @seo_results["saspageseocheck"]["tags"][:robots][:expected]
              offer_step.result = @seo_results["saspageseocheck"]["tags"][:robots][:result] ? 1 : 0
              offer_step.save!
            end
            # only run this if redirect validation was generated by test case
            if(validations.where(step_name: "Cart SEO Robots Tag").empty? == false && @seo_results["cartpageseocheck"].nil? == false)
              # Update record for Robots
              offer_step = validations.where(step_name: "Cart SEO Robots Tag").first
              offer_step.actual = @seo_results["cartpageseocheck"]["tags"][:robots][:actual]
              offer_step.expected = @seo_results["cartpageseocheck"]["tags"][:robots][:expected]
              offer_step.result = @seo_results["cartpageseocheck"]["tags"][:robots][:result] ? 1 : 0
              offer_step.save!
            end

            # only run this if redirect validation was generated by test case
            if(validations.where(step_name: "Confirmation SEO Robots Tag").empty? == false && @seo_results["confirmationseocheck"].nil? == false)
              # Update record for Robots
              offer_step = validations.where(step_name: "Confirmation SEO Robots Tag").first
              offer_step.actual = @seo_results["confirmationseocheck"]["tags"][:robots][:actual]
              offer_step.expected = @seo_results["confirmationseocheck"]["tags"][:robots][:expected]
              offer_step.result = @seo_results["confirmationseocheck"]["tags"][:robots][:result] ? 1 : 0
              offer_step.save!

              # Update record for Confirmation Number
              conf_num = validations.where(step_name: "Confirmation Number").first
              conf_num.actual = (@order_id != 'N/A' && @order_id != nil) ? 'Exists' : 'Does not exist'
              if(conf_num.actual == conf_num.expected)
                  conf_num.result = 1
              else
                  conf_num.result = 0
              end
              conf_num.save!   
            end
       

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

        ##
        # uses all known buttons on the way to order page to get to order page
        def go_to_orderpage()
            locat = Locator.where(brand: 'all', offer: 'orderplacementlocators')
            if(@browser.first('.special-offers-popup') || @browser.first('.popover') || @browser.first('.tv0ffer-popup') || @browser.first('#notify'))
              homepage_popovers
              sleep(2)
            end
            Rails.logger.info "clicking order now"

            locat.where(step: "order_now").each do |locator|
              begin
                @browser.first(:css, locator.css).click()
              rescue => e

              end
            end

            sleep(3)
            if(@browser.first('.special-offers-popup') || @browser.first('.popover') || @browser.first('.tv0ffer-popup') || @browser.first('#notify'))
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
        end

        ##
        # Grabs locator data for this validation and then runs the header and then the footer checks
        def check_header_and_footer()
          locators = Locator.where(brand: 'all', step: 'vanityuci')
          header_check(locators)
          footer_check(locators)
          return true
        end

        ##
        # checks for all known header selectors
        def header_check(locators)
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
          passing = false
          locators.where(offer: 'footer').each do |locator|
            passing = true if browser.first(locator.css)
          end
          raise "Could Not Find Footer" if passing == false
        end

         # prevent login popups on proactiv websites and meaningfulbeauty on QA
        def auth_workarounds(url)
          # crepeerase workaround
          if(url.include?('crepeerase') && url.include?('.grdev.'))
            env = url.scan(/.crepeerase.([^.]+)/).first.first
            @browser.driver.browser.get "https://storefront:Grcweb123@www.crepeerase.#{env}.dw2.grdev.com"
          end
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

           ### SAS and CART canonical tags validation
        def canonical_tag_validation(canonical_tag)
          canonical_url_from_site = @browser.find(canonical_tag, :visible => false)['href']
          canonical_url_split = canonical_url_from_site.split('com')[-1]         
          
          if canonical_url_split.match(/([\/]$)/)
            @canonical_split = canonical_url_from_site.gsub('https','http').gsub('order','')
          elsif canonical_url_split.match(/^\/(?:order)$/)
            @canonical_split = canonical_url_from_site.gsub('https','http').gsub('order','')
          elsif canonical_url_split.include?("/on/demandware.store/Sites-SheerCover-Site/default/COCart-AddProduct")   
            @canonical_split = canonical_url_from_site.gsub('https','http').gsub('on/demandware.store/Sites-SheerCover-Site/default/COCart-AddProduct','')
          elsif canonical_url_split.match(/^\/(?:order\?lang=default)/)
            @canonical_split = canonical_url_from_site.gsub('https','http').gsub('order?lang=default','')
          elsif canonical_url_split.match(/^\/(?:order\.html\?lang=default)/)          
            @canonical_split = canonical_url_from_site.gsub('https','http').gsub('order.html?lang=default','')
          elsif canonical_url_split.match(/^\/(?:en_us\/order)/)
            @canonical_split = canonical_url_from_site.gsub('https','http').gsub('en_us/order','')                  
          end
          return @canonical_split
        end

        ### Find Seo Tags
        def find_canonical(canonical_tag, page)
          begin
            if @browser.first(canonical_tag, :visible => false).nil?
              return false
            else
              @base_url = @browser.current_url.match(/(https?:\/\/[^\/]+\/?)/).captures[0].gsub('https','http')             
              valid_canonical_tag = canonical_tag_validation(canonical_tag)        
              if @base_url.include?(valid_canonical_tag)

              #if @browser.current_url.match(/(https?:\/\/[^\/]+\/?)/).captures[0].gsub('https','http').include?(@browser.find(canonical_tag, :visible => false)['href'].gsub('https','http').gsub('/order',''))
                
                begin
                  campaign = @browser.evaluate_script("omnCampaignID")
                rescue
                  campaign = @browser.evaluate_script("app.omniMap.CampaignID")
                end
                #has_slash_order = @browser.find(canonical_tag, :visible => false)['href'].match(/\/order/)
                #if(page == "Home" && campaign.downcase.include?("core"))
                  if(page == "Home")
                  has_slash_order = @browser.find(canonical_tag, :visible => false)['href'].match(/\/order/)
                else
                  has_slash_order = @browser.find(canonical_tag, :visible => false)['href']
                end                
                
                if(page == "Home")
                  if !has_slash_order
                    return true
                  else
                    return false
                  end
                else
                  if has_slash_order
                    return true
                  else
                    return false
                  end
                end
              else
                return false
              end
            end
          rescue => e
            return false
          end
        end

        # find robots tag present?
        # returns whether robots was found based on tag given
        def find_robots?(robots_tag)
          # if robots not found
          if @browser.first(robots_tag, :visible => false).nil?
            # return false if not present
            return false
          else
            # return true if present
            return true
          end
        end

        def find_tags(page)
          # realm = TestRun.find(@id).realm
          # core = custom_settings['is_core']

          can_present = SeoValidation.where(page_name: page, validation_type: 'canonical').first.present
          canonical_tag = SeoValidation.where(page_name: page, validation_type: 'canonical').first.value
          rob_present = SeoValidation.where(page_name: page, validation_type: 'robots').first.present
          robots_tag = SeoValidation.where(page_name: page, validation_type: 'robots').first.value

          canonical = find_canonical(canonical_tag, page)
          robots = find_robots?(robots_tag)
          canonical_result = (canonical == can_present)
          robots_result = (robots == rob_present)
          return {robots: {expected: rob_present, actual: robots, result: robots_result}, canonical: {expected: can_present, actual: canonical, result: canonical_result}}
        end

        ### Find Redirect codes
        ########### only runs on the first page hit
        def get_redirect_code(url)
          passed = true
          bad_codes = [204,206,400,404,408,500,501,502,503,504,505]



          counter = 0
          possible_redirect = []
          code = nil

          # Collect codes
          while code != 200 && bad_codes.include?(code) == false  do
            possible_redirect << @entries[counter].response.status
            
            puts @entries[counter].response.status
            code = @entries[counter].response.status
            counter = counter + 1
          end

          # 301 Wrong Scenario test
          if(@url.include? "maxRedirect=true")
            if(possible_redirect.include?(301))
              # begin
              #   campaign = @browser.evaluate_script("omnCampaignID")
              # rescue
              #   campaign = @browser.evaluate_script("app.omniMap.CampaignID")
              # end

              # if campaign.downcase.include?("core") == false
                passed == false
              # end
            end
          end

          possible_redirect.each do |code_to_check|
            if bad_codes.include?(code_to_check)
              passed == false
            end
          end


          return {result: passed, codes: possible_redirect}
        end


        def page_name
          page_name = ''
          begin
            
            page_name     = @browser.evaluate_script('s.pageName');
          rescue => e
            begin
              page_name     = @browser.evaluate_script('mmPageName');
              raise 'wrong page' if(page_name.empty?)
            rescue => e
              begin
                begin 
                  page_name     = @browser.evaluate_script('app.omniMap.PageName') if(page_name.empty?)
                rescue => e
                  found_conf = ""
                end
                page_name     = @browser.evaluate_script('visitorLogData.pageId') if(page_name.empty?)
                raise 'wrong page' if(page_name.empty?)
              rescue => e

              end
            end
          end

          return page_name
        end

        # function for checking the SEO file presence and content
        def check_seo_file(file_obj, url_host)
          content_actual = nil
          
          # set failure to true and change if test passes
          failed_file = true

          ## Get Actual Content from URL
          begin
            f = open(file_obj.targeturl) 

              ## Check Status Codes
              if(f.status[0] == "200" && f.status[1] == "OK")

                ## Get the content and strip out carriage returns (\r)
                content_actual = f.readlines.join().gsub("\r",'')

                ## Check the content matches the DB
                if(content_actual == file_obj.valid_content.gsub("\r",""))
                  
                  failed_file =false
                else

                  failed_file = true
                end
              else

                failed_file = true
              end
          rescue => e
            begin
              f.close()
            rescue

            end
            return [false, content_actual, e.message]
          end

          return [failed_file == false, content_actual]
        end
    end
end