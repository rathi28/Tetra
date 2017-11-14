module GRTesting

  ##
  # Standard Buyflow Class used for Offer code testing and for Buyflow tests
  class BuyflowTest < WebTest

    # Configuration variable which holds the campaign configuration as a hash variable
    # @api private
    @configuration = nil

    # Offercode variable which holds the current offer
    # @api private
    @offer = []

    def initialize(title: 'Testcase', browser: 'ie11', configuration: nil, offer_code: nil, id: nil)
      puts title
      puts browser
      puts configuration
      puts offer_code
      puts id
      puts "start buyflow initialize"
      super(title: title, browser: browser, id: id)
      @configuration = configuration
      puts @configuration['DesktopSASPagePattern']
      catch_simple do
        offer_code = nil if offer_code.strip.empty?
      end
      @offer = []
      if(offer_code.nil?)
        @offer = nil
      else
        puts "hi else"
        begin
          @campaign = Campaign.find(@configuration['id'])
          puts "offercode after campaign"
          puts offer_code
          if(offer_code.include?(';'))
            offer_array = offer_code.split(';')
            offer_array.each do |offer|
              puts "splitted offer"
              puts offer
              offer_entry = @campaign.offerdata.where(:offercode => offer).last()
              puts "offer entry"
              puts offer_entry
              @offer.push(offer_entry)
            end
          else
            # @campaign = Campaign.find(@configuration['id'])
            # @offer = @campaign.offerdata.where(:offercode => offer_code).last()
            offer_entry = @campaign.offerdata.where(:offercode => offer_code).last()
            @offer.push(offer_entry)
          end
        rescue => e
          @offer = nil
        end
      end
      @offer.each do |offer|
        puts offer['OfferCode']
      end
      # add a report object for storing buyflow information
      @report.buyflow_report  = GRReporting::BuyflowReport.new()

      # add a report object for storing UCI specific data     
      @report.uci_report      = GRReporting::UCIReport.new()
      puts "stop buyflow initialize"
    end

    ##
    # Test Steps executed before test cases
    def before

      # executes before anything else
      super()
      
      # instatiate the starting page model
      @page                   = T5::Marketing.new(@configuration)
      
      # set the browser session to the current one held by the test case
      @page.browser           = @browser
      
      # adapt the page based on the configuration settings
      @page                   = @page.adapt

    end

    ##
    # Test Steps executed for test cases
    # TODO DOCUMENTATION - DETAIL STEPS
    def execute
      super()

      # executes test case info

      # workaround pages that need to login to secondary domains
      auth_workarounds()

      # Change this to 0 to get retries in buyflow test
      timeout_count = 1 
      
      begin
        puts @report.url

        # Navigate to the site
        @page.browser.driver.browser.get @report.url if(@report.url)





        # ------------ Marketing section, Landing Page ------------ 

        @report.browser                 = @page.browser_name


        # pull the operating System from the user agent or other sources
        @report.os                      = @page.os_name

        # pull the brand from the page variables or domain
        @report.buyflow_report.brand    = @page.brand

        # pull the uci code from omniture
        @report.uci_report.uci_mp       = @page.uci

        if(@configuration['Brand'] == 'Marajo' || @configuration['Brand'] == 'smileactives')
          puts "products hiiiiiiiii"
          @page = @page.go_to_productpage()
          puts "done product button"
        else
          puts "going to order page"
          @page = @page.go_to_orderpage()
          puts @page
          puts "done fetching orderpage"
        end

        # navigate to the SAS page if that page section isn't present.
        # @page                           = @page.go_to_orderpage()




        @report.buyflow_report.lastpagefound = "sas"

        # ------------ SAS Section ------------ 

        @report.uci_report.uci_sas                   = @page.uci
        
        # If an offer is not present in test
        if(@offer == nil)
          # navigate to the cart using default options
          @page                             = @page.skip_to_cart
        else
          # ...otherwise select the options defined by the offer
         
          @page                             = @page.select_options(@offer)
        end

        # exclude_from_selection_workaround = BrandsExcludedSelectionWorkaround.all.select('brand').collect(&:brand)
        # if(@offer)
        #   if(timeout_count == 1 && @offer['OfferCode'])
        #     if(exclude_from_selection_workaround.include?(@configuration["Brand"].downcase) == false)
        #       selection_workaround(@page.browser)
        #     end
        #   end
        # end

        


puts "Proceed to cart section"

        # ------------ Cart Section ------------ 

        @report.uci_report.uci_op                   = @page.uci

        @report.buyflow_report.lastpagefound = "cart"

        @report.buyflow_report.offer_code = @page.offercode
        puts "offercode"
        puts @report.buyflow_report.offer_code

        @report.grcid = @page.grcid
        puts "grcid"
        puts @report.grcid

        # catch_and_display_error do

          @report.buyflow_report.total_pricing = @page.total_pricing
          puts "total_pricing"
          puts @report.buyflow_report.total_pricing

          @report.buyflow_report.subtotal_price     = @page.subtotal_price
          puts "subtotal_price"
          puts @report.buyflow_report.subtotal_price

          # pull the pricing for the SAS for any sections still in the same page as the cart
          begin
            @report.buyflow_report.saspricing           = @page.check_sas_pricing(@report.buyflow_report.subtotal_price)
          rescue => e
            @report.buyflow_report.saspricing           =  "No Offer Associated with this Test"
          end
    
          @report.buyflow_report.saspricing           = '' if @report.buyflow_report.saspricing == nil
          puts "saspricing"
          puts @report.buyflow_report.saspricing
          @report.buyflow_report.sasprices            = @page.check_sas_prices
          puts "sasprices"
          puts @report.buyflow_report.sasprices

          # pull the cart description from the order summary section
          @report.buyflow_report.cart_language      = @page.cart_description
          puts "cart description"
          puts @report.buyflow_report.cart_language

          @report.buyflow_report.cart_title = @page.cart_title
          puts "productname"
          puts @report.buyflow_report.cart_title

          @report.buyflow_report.sas_kit_name       = @page.check_sas_kit_name(@report.buyflow_report.cart_title)

          @report.buyflow_report.kitnames           = @page.cart_title

          @report.buyflow_report.cart_quantity = @page.quantity
          puts "quantity"
          puts @report.buyflow_report.cart_quantity

          if(@report.buyflow_report.cart_quantity.nil?)
            @report.buyflow_report.cart_quantity = "[Quantity Dropdown Missing] - Locator may be missing"
          end

          @report.buyflow_report.shipping_standard  = @page.shipping('Standard')
          puts "shipping"
          puts @report.buyflow_report.shipping_standard
          
          # Rush Shipping
          @report.buyflow_report.shipping_rush      = @page.shipping('Rush') 

          # Overnight Shipping
          @report.buyflow_report.shipping_overnight = @page.shipping('Overnight')

          @report.buyflow_report.shipping_standard = 'N/A' if @report.buyflow_report.shipping_standard.nil?
        
          @report.buyflow_report.shipping_rush = 'N/A' if  @report.buyflow_report.shipping_rush.nil?

          @report.buyflow_report.shipping_overnight = 'N/A' if @report.buyflow_report.shipping_overnight.nil?

          if(@offer)
            @offer.each do |offer|
              # Continuity Shipping        
              @report.buyflow_report.continuity_shipping = @page.continuity(offer)
              puts "Continuity"
              puts @report.buyflow_report.continuity_shipping
            end
          end
        # end

        # get the shipping selection price
        puts "cart_shipping_selection_price"
        cart_shipping_selection_price = @page.current_shipping_cost
        puts cart_shipping_selection_price

        @page.place_order(@configuration['ConfEmailOverride'])

        # Submit order in order to reach confirmation page
        @page = @page.submit_order

        # ------------  Confirmation Page ------------

        puts "proceeding to confirmation page"

        @page.expand_order_details()
          
        # pull the confirmation number
        @report.buyflow_report.confirmation_number = @page.get_confirmation_number

        @report.buyflow_report.lastpagefound = "confirmation page"
        # pull the uci number for the confirmation page
        @report.uci_report.uci_cp = @page.uci

        # Compare the billing and shipping information to the data that was entered in the cart
        check_billing_info(@report.buyflow_report, @page)

        # get the offer code from the confirmation page
        @report.buyflow_report.confoffercode = @page.offercode

        # get the confirmation page pricing for the main product
        @report.buyflow_report.confpricing = @page.confpricing

        # check the shipping price matches the shipping selected in the cart
        puts "shipping_conf"
        shipping_conf = @page.conf_shipping_price
        puts shipping_conf

        if(shipping_conf == cart_shipping_selection_price)
          @report.buyflow_report.shipping_conf = "match"
          @report.buyflow_report.shipping_conf_val = shipping_conf
          @report.buyflow_report.selected_shipping = cart_shipping_selection_price
        else
          begin
            @report.buyflow_report.shipping_conf_val = shipping_conf

          rescue
          end
          begin
            @report.buyflow_report.selected_shipping = cart_shipping_selection_price
          rescue

          end
          begin
            @report.buyflow_report.shipping_conf = shipping_conf.to_s + " - expected: " + cart_shipping_selection_price.to_s
          rescue
            @report.buyflow_report.shipping_conf = "Problem with gathering data: confirmation - " + shipping_conf.class.to_s + " cart - " + cart_shipping_selection_price.class.to_s
          end
        end

        @report.buyflow_report.conf_kit_name = @page.cart_title

        # -------- Failure Checks ---------
        if(@report.grcid.nil?)
          fail 'GRCID not found for this page (AKA Campaign Code)'
        end

        if(@report.uci_report.uci_mp.nil?)
          fail 'UCI code for Marketing section was not found'
        end

        if(@report.uci_report.uci_op.nil?)
          fail 'UCI code for Cart section was not found'
        end
        
        if(@report.uci_report.uci_sas.nil?)
          fail 'UCI code for SAS section was not found'
        end        
        
        if(@report.uci_report.uci_cp.nil?)
          fail 'UCI code for Confirmation page was not found'
        end

        if(@report.buyflow_report.subtotal_price.nil?)
          fail 'subtotal price was not found'
        end

        if(@report.buyflow_report.cart_title.to_s.downcase.include? 'kit')
          if(@report.buyflow_report.cart_language.nil?)
            fail 'cart language was not found'
          end
        end

        if(@report.buyflow_report.cart_title.nil?)
          fail 'cart title was not found'
        end

        # Check Shipping matches given offer if present
        if(@offer)
          if(@offer.length == 1)
            @offer.each do |offer|
              if(@report.buyflow_report.shipping_standard != offer['StartSH'].gsub('$','').strip())
                fail "Shipping price did not match - #{offer.Offer.to_s} - Entry -a #{@report.buyflow_report.shipping_standard} -e #{offer['StartSH'].gsub('$','').strip()}"
              end

              if(@report.buyflow_report.shipping_rush != offer['Rush'].gsub('$','').strip())
                fail "Shipping price did not match - #{offer.Offer.to_s} - Rush -a #{@report.buyflow_report.shipping_rush} -e #{offer['Rush'].gsub('$','').strip()}"
              end

              if(@report.buyflow_report.shipping_overnight != offer['OND'].gsub('$','').strip())
                fail "Shipping price did not match - #{offer.Offer.to_s} - OND -a #{@report.buyflow_report.shipping_overnight} -e #{offer['OND'].gsub('$','').strip()}"
              end
            end
          else
            standard_data = ''
            rush_data = ''
            ond_data = ''
            if((@report.buyflow_report.cart_title.to_s.downcase.include? 'kit') && (@report.buyflow_report.brand == 'Marajo'))
              @offer.each do |offer|
                next unless offer.Offer.to_s.downcase.include? 'kit'
                standard_data = offer['StartSH'].gsub('$','').strip()
                rush_data = offer['Rush'].gsub('$','').strip()
                ond_data = offer['OND'].gsub('$','').strip()
                break
              end
            else
              standard_data = '$0.00'
              @offer.each do |offer|
                rush_data = offer['Rush'].gsub('$','').strip()
                ond_data = offer['OND'].gsub('$','').strip()
                break
              end
            end
            
            if(@report.buyflow_report.shipping_standard != standard_data.gsub('$','').strip())
              fail "Shipping price did not match - #{offer.Offer.to_s} - Entry -a #{@report.buyflow_report.shipping_standard} -e #{standard_data.gsub('$','').strip()}"
            end

            if(@report.buyflow_report.shipping_rush != rush_data)
              fail "Shipping price did not match - #{offer.Offer.to_s} - Rush -a #{@report.buyflow_report.shipping_rush} -e #{rush_data}"
            end

            if(@report.buyflow_report.shipping_overnight != ond_data)
              fail "Shipping price did not match - #{offer.Offer.to_s} - OND -a #{@report.buyflow_report.shipping_overnight} -e #{ond_data}"
            end
          end
        end        

        if(@report.buyflow_report.conf_kit_name.nil?)
          fail 'confirmation kit name was not found'
        end

        if(@report.buyflow_report.confpricing.nil?)
          fail 'confirmation price was not found'
        end

        if(@report.buyflow_report.billname == 'FAILED' || @report.buyflow_report.billaddress == 'FAILED' || @report.buyflow_report.billemail == 'FAILED' || @report.buyflow_report.shipaddress == 'FAILED')
          fail 'The billing/shipping info on the confirmation page did not match data input on cart page'
        end

        if(@report.buyflow_report.shipping_conf != 'match')
          fail 'Shipping did not match cart on confirmation page' 
        end

        if(@report.buyflow_report.confoffercode.nil?)
          fail 'Could not find Offer code on the confirmation page'
        end

        if(@report.buyflow_report.offer_code.nil?)
          fail 'Could not find Offer code on the cart page'
        end

        if(@offer)
          @offer.each do |offer|
            puts @report.buyflow_report.offer_code
            puts @report.buyflow_report.confoffercode
            puts offer.OfferCode.to_s
            if(@report.buyflow_report.expected_offer_code)
              if @report.buyflow_report.offer_code.to_s.downcase.include?(offer.OfferCode.to_s.downcase) == false
                raise "OfferCode didn't match in cart page"
              end
            end

            if(@report.buyflow_report.expected_offer_code)
              if @report.buyflow_report.confoffercode.to_s.downcase.include?(offer.OfferCode.to_s.downcase) == false
                raise "OfferCode didn't match in confirmation page"
              end
            end
# puts offer.offer_data_detail.offerdesc
# puts @report.buyflow_report.cart_language
            if(offer.offer_data_detail)
              if(@report.buyflow_report.cart_language)
                if cleanup_format(@report.buyflow_report.cart_language).include?(cleanup_format(offer.offer_data_detail.offerdesc)) == false
                  raise "Cart language did not match"
                end
              end

              if(@report.buyflow_report.cart_title)
                if @report.buyflow_report.cart_title.to_s.downcase.include?(offer.offer_data_detail.offer_title.to_s.downcase) == false
                  raise "Cart title did not match"
                end
              end
            else
              if(@report.buyflow_report.cart_title)
                if @report.buyflow_report.cart_title.to_s.downcase.include?(offer.Offer.to_s.downcase) == false
                  raise "Cart title did not match"
                end
              end
            end
          end
        end

        # ------- end of testing --------


      rescue T5::PasswordMatchException => e
        raise e

      rescue Net::ReadTimeout, Selenium::WebDriver::Error::UnknownError => e
        net_timeout_timeout = 0
        begin
          net_timeout_timeout += 1
          sleep(5)
          soft_browser_quit()
          # create browser for new attempt
          @browser = BrowserFactory.create_browser(@browsertype)

          # instatiate the starting page model
          @page                   = T5::Marketing.new(@configuration)
          
          # set the browser session to the current one held by the test case
          @page.browser           = @browser
          
          # adapt the page based on the configuration settings
          @page                   = @page.adapt

          auth_workarounds()
          exp = @report.buyflow_report.expected_offer_code
          @report.buyflow_report  = GRReporting::BuyflowReport.new()
          @report.buyflow_report.expected_offer_code = exp
        rescue => exc
          if net_timeout_timeout < 5
            retry
          else
            raise e
          end
        end
        retry
      rescue => e
        timeout_count += 1;
        # Change the limit of retries here.
        raise e if(timeout_count > 1)
        soft_browser_quit()
        @browser = BrowserFactory.create_browser(@browsertype)

        # instatiate the starting page model
        @page                   = T5::Marketing.new(@configuration)
        
        # set the browser session to the current one held by the test case
        @page.browser           = @browser
        
        # adapt the page based on the configuration settings
        @page                   = @page.adapt

        auth_workarounds()
        exp = @report.buyflow_report.expected_offer_code
        @report.buyflow_report  = GRReporting::BuyflowReport.new()
        @report.buyflow_report.expected_offer_code = exp
        retry
      end
    end

    def cleanup_format(string)
      string = string.to_s.gsub("'", "\\\\'").gsub(/[\s]+/,' ')
      return string
    end

    ##
    # If a bad selection is made, make the selection again with some parameters attached to preselect options if possible
    # 
    # @note External Methods used: 
    #
    #   For parsing URLs into a URI -> {http://ruby-doc.org/stdlib-1.9.3/libdoc/uri/rdoc/URI.html#method-c-parse URI.parse(url)}
    #
    #   For parsing querystrings into a hash of keys and values -> {http://ruby-doc.org/stdlib-1.9.3/libdoc/cgi/rdoc/CGI.html#method-c-parse CGI.parse(querystring)}
    #
    def selection_workaround(browser)
      begin
        workaround_url = browser.current_url
        # parse incoming URI into a URI object
        workaround_uri = URI.parse(workaround_url)
        if(workaround_uri.query)
          parameters = CGI.parse(workaround_uri.query)
          parameters['pid'] = [@offer['OfferCode']] if @configuration['Brand'].downcase != 'sheercover' && @configuration['Brand'].downcase != 'perricone' && @configuration['Brand'].downcase != 'wen'
        else
          parameters = {}
          parameters['pid'] = [@offer['OfferCode']] if @configuration['Brand'].downcase != 'sheercover' && @configuration['Brand'].downcase != 'perricone' && @configuration['Brand'].downcase != 'wen'
        end
        workaround_uri.query = URI.encode_www_form parameters
        workaround_url = workaround_uri.to_s
        browser.driver.browser.get workaround_url if(workaround_url)
      rescue => e
        Rails.logger.info e.message
        Rails.logger.info e.backtrace if e.backtrace
      end
    end

    ##
    # This is a test helper for checking whether the confirmation page has all the data it should
    def check_billing_info(report, page)
      begin
        if(page.bill_name.downcase.include? "digital automation")
          report.billname     = page.bill_name
        else
          report.billname     = 'FAILED'
        end
      rescue => e
        report.billname     = 'FAILED'
      end

      begin
        if(page.billing_address.include?("123 QATest Street") && page.billing_address.include?('Anywhere') && page.billing_address.include?('CA') && page.billing_address.include?('90405'))
          report.billaddress     = page.billing_address
        else
          report.billaddress     = 'FAILED'
        end
      rescue => e
        report.billaddress     = 'FAILED'
      end
      
      begin
        if(page.shipping_address.include?("123 QATest Street") && page.shipping_address.include?('Anywhere') && page.shipping_address.include?('CA') && page.shipping_address.include?('90405'))
          report.shipaddress  = page.shipping_address
        else
          report.shipaddress  = 'FAILED'
        end
      rescue => e
        report.shipaddress  = 'FAILED'
      end

      begin
        if(page.bill_email.include? @configuration['ConfEmailOverride'])
          report.billemail   = page.bill_email
        else
          report.billemail = 'FAILED'
        end
      rescue => e
        report.billemail = 'FAILED'
      end
    end

    def after
      super()
       # get the record for this test run
      run = Testrun.find(@id)

      begin
        # Recoridng the error to the database as an ErrorMessage Object
        if(@errors.first)
          error_obj = ErrorMessage.new()
          error_obj.class_name = @errors.first.class.to_s
          error_obj.message = @errors.first.message
          error_obj.backtrace = @errors.first.backtrace.join("\n")
          error_obj.testrun_id = run.id
          error_obj.save!
        end
      rescue => e

      end
    end

    ##
    # This method accesses the required domains for certain brands that use other servers to handle some actions during a order. This only happens in the QA environment and should be ignored otherwise.
    # @note Any additional work arounds needed should be encapsulated in a brand check to make sure the right brand is loading that page, and a check that this is a QA environment URL
    def auth_workarounds()
      # if(@configuration['Brand'].downcase.include?('proactiv') && @report.url.include?('.grdev.'))
      #   Rails.logger.info 'working around auth popups'
      #   env = @report.url.scan(/.proactiv.([^.]+)/).first.first
      #   @page.browser.driver.browser.get "https://storefront:Grcweb123@proactiv.#{env}.dw.grdev.com"       
      #   @page.browser.driver.browser.get "https://storefront:Grcweb123@proactiv.#{env}.dw.grdev.com/on/demandware.store/Sites-Proactiv-Site/default/RedirectURL-Hostname"
      #   @page.browser.driver.browser.get "https://storefront:Grcweb123@original.proactiv.#{env}.dw.grdev.com"
      #   @page.browser.driver.browser.get "https://storefront:Grcweb123@mypa.proactiv.#{env}.dw.grdev.com"
      #   @page.browser.driver.browser.get "http://storefront:Grcweb123@mypa.proactiv.#{env}.dw.grdev.com/on/demandware.store"
      # end

      if(@configuration['Brand'].downcase == 'crepeerase' && @report.url.include?('.grdev.'))
        env = @report.url.scan(/.crepeerase.([^.]+)/).first.first
        @page.browser.driver.browser.get "https://storefront:Grcweb123@www.crepeerase.#{env}.dw2.grdev.com"
      end

      if(@configuration['Brand'] == 'MeaningfulBeauty' && @report.url.include?('.qa.'))
        Rails.logger.info 'working around auth popups'
        @page.browser.driver.browser.get "https://storefront:Grcweb123@catalog-meaningfulbeauty.stg01.dw.grdev.com"
      end
    end
  end
end