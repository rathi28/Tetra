##
#
module T5
  ##
  # The base class on which all Templated websites are built off of
  class BasePage < ::WebPage
    # @!attribute [r] campaign_configuration 
    #   A hash object containing key-value pairs for all the campaign/test settings
    attr_reader :campaign_configuration
    attr_accessor :email

    ##
    # Creates the page
    # @param [Hash] campaign_configuration A hash object containing key-value pairs for all the campaign/test settings
    def initialize(campaign_configuration)
      @price_regex = /\d+\.\d+/ 
      super()
      # Store the passed in configuration to the class variable
      @campaign_configuration = campaign_configuration      
    end # of initialize

    def get_pattern
      # pull the pattern string from the configuration
      pattern = @campaign_configuration['DesktopSASPagePattern']
      # parse out the page structure from the given pattern
      structure = pattern_parser(pattern)
      return structure
    end

    def page_name
      page_name = ''
      begin
        page_name     = @browser.evaluate_script('mmPageName');
        raise 'wrong page' if(page_name.empty?)
        
        page_campaign = @browser.evaluate_script('mmCampaign');
        page_uci      = @browser.evaluate_script('mmUCI');
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

      begin
        if(page_name.downcase.include?("conf") == false)
          raise "Wrong page"
        end
      rescue => e
        begin
          begin
            found_conf = @browser.evaluate_script('visitorLogData.pageId');
          rescue => e
            found_conf = ""
          end
          if(found_conf.downcase.include?("conf"))

          else
            raise "Wrong page"
          end
        rescue => e
          #raise e
        end
      end
      return page_name
    end

    # Parses the page pattern from configuration to get an array of pages and steps on the pages
    def pattern_parser(pattern)
      page_pattern = []
      pages = pattern.split('|')
      pages.each do |page|
        page_pattern.push page.split('_')
      end
      page_pattern.each do |page|
        page.each do |step|
          step.capitalize!
        end
      end
      return page_pattern
    end

    def get_browserdata
      return GRDatabase.get_browsertypes(campaign_configuration['platform'])
    end

    ##
    # Returns a boolean value of whether this experience is going to be desktop or mobile.
    # If this driver doesn't have a browsertype entry in the database, it will throw an error
    def desktop?
      data    = get_browserdata
      result  = data.entries.first['device_type'] == 0
      return result
    end

    ##
    # Returns a boolean value of whether this driver is remotely located
    # raises an error if the driver does not have a Browsertype entry in the database
    def remote?
      data    = get_browserdata
      result  = data.entries.first['remote'] == 1
      return result
    end

    def brand
      attempts = 0
      begin
        brand = @campaign_configuration["Brand"]
        if(brand.gsub(/[\"\']/, "").empty?)
          if(@browser.url.include? "wen")
            return "Wen"
          else
            return "Brand Not Found"
          end
        end
      rescue => e
        attempts += 1
        sleep(1)
        retry if attempts < 3
        raise e
      end
      return brand
    end

    # Page Information Getters

    def offercode()
      locat = Locator.where(brand: 'all', offer: 'orderplacementlocators')
      offercode = nil
      locat.where(step: "coreid").each do |locator|
        begin
          ofcode = @browser.first(:css, locator.css, :visible => false).value
          if ofcode
            offercode = ofcode.strip
          else
            raise 'text?'
          end
        rescue => e
          begin
            ofcode = @browser.first(:css, locator.css, :visible => false).text
            if ofcode
              offercode = ofcode.strip
            end
          rescue => e

          end
        end
      end
      return offercode
    end

    ##
    # Returns the campaign code for this page
    # @param [String] javascript_variable The GRCID variable in javascript that needs to be called
    def grcid(javascript_variable: 'omnGrcid')
      begin      
       grcid_code = js_return(javascript_variable)
       if(grcid_code)
         return grcid_code         
       else
        if (js_return 'app.omniMap.CampaignID')
          return js_return 'app.omniMap.CampaignID'          
        else  
          return 'N/A'          
        end  
       end
      rescue => e
       return 'N/A'
      end  
    end

    ##
    # Returns the Unique Campaign Identifier for the current page - different from GRCID and deals with entry method and tracking
    # @param [String] javascript_variable The UCI variable in javascript that needs to be called
    # @return [object] javascript response (can be a string, can be an object)
    def uci(javascript_variable: 's.campaign')
      
      uci_code = js_return(javascript_variable)

      if(uci_code)
        return uci_code
      else
        return 'N/A'
      end
    end

    def get_confirmation_number()
      
      confirmation_num = ''
      confirmation_locators = Locator.where(brand: 'All', step: 'ConfNum', offer: 'All')
      confirmation_locators.each do |conf_num_locator|
        begin
          confirmation_num = @browser.find(conf_num_locator.css).text().match(/:\s*([^\s\/\:]{6,})/) if(@browser.first(conf_num_locator.css))
        rescue => e

        end
      end
      begin
        return confirmation_num.captures.first
      rescue => e
        return ''
      end
    end

    def place_order(email)
      @email = email
      locat = Locator.where(brand: 'all', offer: 'orderplacementlocators')

      Rails.logger.info "clicking order now"

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

      sleep(3)

      locat.where(step: "order_now").each do |locator|
        begin
          @browser.first(:css, locator.css).click()
        rescue => e

        end
      end

      begin
        if(@browser.current_url.include?('reclaimbotanical'))
          sleep(5)
          @browser.find(:css, 'a.closebtn').click()
        end
      rescue => e

      end

      Rails.logger.info "filling out email"
      locat.where(step: "emailfield").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => (@email))
        rescue => e

        end

      end

      locat.where(step: "fullphone").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => '9999999999')
        rescue => e

        end
      end

      locat.where(step: "phone1").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => '999')
        rescue => e

        end
      end

      locat.where(step: "phone2").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => '999')
        rescue => e

        end
      end

      locat.where(step: "phone3").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => '9999')
        rescue => e

        end
      end


      Rails.logger.info "filling out billing"

      locat.where(step: "firstname").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => 'Digital')
        rescue => e

        end
      end

      locat.where(step: "lastname").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => 'Automation')
        rescue => e

        end
      end

      locat.where(step: "address1").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => '123 QATest Street')
        rescue => e

        end
      end
      
      # twice to avoid geolocation request problem
      locat.where(step: "address1").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => '123 QATest Street')
        rescue => e

        end
      end

      locat.where(step: "city").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => 'Anywhere')
        rescue => e

        end
      end

      locat.where(step: "zip").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => '90405')
        rescue => e

        end
      end

      locat.where(step: "state").each do |locator|
        begin
          @browser.find_field(locator.css).find("option[value='CA']").select_option
          # @browser.find(:css, locator.css).find("option[value='CA']").select_option
          # @browser.find(:css, locator.css).select('CA')
        rescue => e

        end
      end

      locat.where(step: "state").each do |locator|
        begin
          @browser.find_field(locator.css).find("option[value='California']").select_option
          # @browser.find(:css, locator.css).find(:option, 'California').select_option
          # @browser.find(:css, locator.css).select('California')
        rescue => e

        end
      end

      begin
        if(@browser.current_url.include?('reclaimbotanical'))
          sleep(5)
          begin
            @browser.find(:css, 'a.closebtn').click()
          rescue => e
            
          end
          locat.where(step: "contyourorder").each do |locator|
            begin
              @browser.first(:css, locator.css).click()
            rescue => e

            end
          end
        end
      rescue => e

      end

      Rails.logger.info "filling out credit card"

      locat.where(step: "ccnumber").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => '4111111111111111')
        rescue => e

        end
      end

      locat.where(step: "ccmonth").each do |locator|
        begin
          @browser.find_field(locator.css).find("option[value='10']").select_option
          # @browser.find(:css, locator.css).select('07')
        rescue => e

        end
      end

      locat.where(step: "ccmonth").each do |locator|
        begin
          @browser.find_field(locator.css).find("option[value='July']").select_option
          # @browser.find(:css, locator.css).select('July')
        rescue => e

        end
      end

      locat.where(step: "paymentmethod").each do |locator|
        begin
          @browser.find_field(locator.css).select('Visa')
          # @browser.find(:css, locator.css).select('Visa')
        rescue => e

        end
      end

      locat.where(step: "ccyear").each do |locator|
        begin
          @browser.find_field(locator.css).find("option[value='2019']").select_option
          # @browser.find(:css, locator.css).select('2017')
        rescue => e

        end
      end

      locat.where(step: "agreecheck").each do |locator|
        begin
          @browser.find_field(locator.css).click()
          # @browser.find(:css, locator.css).click()
        rescue => e
         
        end
       begin
          @browser.first(:css, locator.css, :visible => false).set(true)
        rescue => e

        end
      end

      Rails.logger.info "Completing order"
      (0..3).each do 
        catch_simple do
          @browser.all('#contYourOrder').last.click()
        end
      end

      locat.where(step: "contyourorder").each do |locator|
        begin
          @browser.first(:css, locator.css).click()
        rescue => e

        end
      end


      

      begin
        sleep(3)
        locat.where(step: "contyourorder").each do |locator|
        begin
          @browser.first(:css, locator.css).click()
        rescue => e

        end
      end
      locat.where(step: "contyourorder").each do |locator|
        begin
          @browser.first(:css, locator.css).click()
        rescue => e

        end
      end
        sleep(3)
      locat.where(step: "contyourorder").each do |locator|
        begin
          @browser.first(:css, locator.css).click()
        rescue => e

        end
      end
      locat.where(step: "contyourorder").each do |locator|
        begin
          @browser.first(:css, locator.css).click()
        rescue => e

        end
      end
    rescue => e

      end

      begin
        sleep(3)
        locat.where(step: "contyourorder").each do |locator|
        begin
          @browser.first(:css, locator.css).click()
        rescue => e

        end
      end
      locat.where(step: "contyourorder").each do |locator|
        begin
          @browser.first(:css, locator.css).click()
        rescue => e

        end
      end
        sleep(3)
      locat.where(step: "contyourorder").each do |locator|
        begin
          @browser.first(:css, locator.css).click()
        rescue => e

        end
      end
      locat.where(step: "contyourorder").each do |locator|
        begin
          @browser.first(:css, locator.css).click()
        rescue => e

        end
      end
      rescue => e
        
      end
    end

    

  end # of BasePage Class

  # Exception for unimplemented 'interface-like' classes
  class UnimplementedMethod < RuntimeError

  end # of UnimplementedMethod Class

end # of T5 module
