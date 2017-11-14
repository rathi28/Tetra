module T5
  class PasswordMatchException < RuntimeError

  end
  class Confirmation < BasePage
    def close_popups
      Rails.logger.info "Mitigating Popups"
      close_btns = Locator.where(:step => 'PopupClose')
      
      close_btns.each do |close_btn|
        click_if_exists(:css, close_btn.css)
      end
      @browser.windows.each do |window|
        window.close if(window.current? == false)
      end
    end

    def billing_address
      locators = GRDatabase.get_all_locators('confirmation', 'all', 'billing_address')
      return_first_text_from_query_locators locators
    end
    
    def confpricing
      locators = GRDatabase.get_all_locators('confirmation', 'all', 'confpricing')
      return_first_text_from_query_locators locators
    end 
    
    def confvitaminpricing
      locators = GRDatabase.get_all_locators('confirmation', 'all', 'confvitaminpricing')
      return_first_text_from_query_locators locators
    end 
    
    def conf_shipping_price
      locators = GRDatabase.get_all_locators('confirmation', 'all', 'conf_shipping_price')
      begin
        price_string = return_first_text_from_query_locators locators
        if(@campaign_configuration['Brand'].downcase == "supersmile")
          return price_string.scan(@price_regex)[1]
        end
        return price_string.scan(@price_regex).first()
      rescue => e
        Rails.logger.info e
        return nil
      end
    end 
    
    def kit_name
      locators = GRDatabase.get_all_locators('confirmation', 'all', 'kit_name')
      return_first_text_from_query_locators locators
    end 
    
    def vitamin_name
      locators = GRDatabase.get_all_locators('confirmation', 'all', 'vitamin_name')
      return_first_text_from_query_locators locators
    end 
    
    def shipping_address
      locators = GRDatabase.get_all_locators('confirmation', 'all', 'shipping_address')
      return_first_text_from_query_locators locators
    end

    def bill_name
      locators = GRDatabase.get_all_locators('confirmation', 'all', 'bill_name')
      return_first_text_from_query_locators locators
    end

    def bill_email
      locators = GRDatabase.get_all_locators('confirmation', 'all', 'bill_email')
      return_first_text_from_query_locators locators
    end

    def offercode
      begin
        if(@browser.has_selector?(:xpath, './/span[@class="offerCode"]'))
          offercode_array = []
          locators = @browser.all(:xpath, './/span[@class="offerCode"]')
          locators.each do |offercode|
            puts "locator"
            puts offercode
            offercode_array.push(offercode.text)
          end
          offercode_string = offercode_array.join(';')
          puts "confirmation offercode"
          puts offercode_string
          return offercode_string
        else
          product_string = @browser.first('#orderSummary_0')
          offercode = product_string.text().strip().split(/[^\S]+/)[0]
          return offercode
        end
      rescue => e
        return js_return "app.omniMap.MainOfferCode"
      end      

    end

    def cart_title
      begin
        if(@browser.has_selector?(:xpath, './/span[@class="productName"]'))
          name_array = []
          locators = @browser.all(:xpath, './/span[@class="productName"]')
          locators.each do |product|
            puts "locator"
            puts product
            name_array.push(product.text)
          end
          name_string = name_array.join(';')
          puts "confirmation cart title"
          puts name_string
          return name_string
        else
          product_string = @browser.first('#orderSummary_0')
          kitname = product_string.text().strip().split(' - ')[1]
          return kitname
        end
      rescue => e
        
      end      
    end

    # def offercode()
    #   begin
    #     product_string = @browser.first('#orderSummary_0')
    #     offercode = product_string.text().strip().split(/[^\S]+/)[0]
    #     if(@campaign_configuration['Brand'].downcase.include?('reclaim'))
    #       raise 'reclaim workaround'
    #     end
    #     if(@campaign_configuration['Brand'].downcase == "supersmile")
    #       raise 'supersmile workaround'
    #     end
    #     offercode
    #   rescue => e
    #     if(@campaign_configuration['Brand'].downcase == "supersmile")
    #       return kit_name.scan(/[^\s]+/).first
    #     else
    #         return js_return 'mainOfferCode'
    #     end
    #   end
    #   begin
    #    if(js_return 'app.omniMap.MainOfferCode')
    #      if(offercode.length.to_s != 6)
    #       return js_return "app.omniMap.MainOfferCode"
    #     end
    #    else
    #      return offercode
    #    end
    #   rescue => e
    #     return offercode
    #   end
    #   return offercode
    # end

    def get_confirmation_number
      begin
        @browser.find(:xpath, './/span[@id="orderConfirmNum"]').text
      rescue => e

      end
    end

    def expand_order_details()
      begin
        if(@browser.has_selector?(:css, 'div.show-order-details-button a.button'))
          @browser.find(:css, 'div.show-order-details-button a.button').click
        end
      rescue => e

      end
    end

  	# def get_confirmation_number()
   #    @confirmation_number_fields = Locator.where(:step => 'ConfNum')
   #    confirmation_num = 'N/A'
   #    #Rails.logger.info 'Getting Confirmation Number from Confirmation Page'
   #    timeout = 0
   #    begin
   #      check_if_page_ready
   #      click(:css, '#vieworderdetails') if(@browser.first('#vieworderdetails'))
   #      #Block added to expand the first contact mobile page - ssankara - next 4 lines
   #      if(@browser.first('.more-less'))
   #          click_if_exists(:css, '.more-less')
   #        if(@browser.first('.more-less .plus'))
   #          click_if_exists(:css, '.more-less .plus')
   #        end
   #      end

   #      if(@campaign_configuration['Brand'] == "Supersmile")
   #        begin

   #          if @browser.all('.CartForm b').empty?

   #          else
   #            confirmation_num = @browser.all('.CartForm b').first.text
   #            return confirmation_num
   #          end
   #        rescue

   #        end
   #      else
   #        @confirmation_number_fields.each do |conf_num_locator|
   #          confirmation_num = @browser.find(conf_num_locator.css).text().match(/:\s*([^\s\/\:]{6,})/) if(@browser.first(conf_num_locator.css))
   #          #confirmation_num = @browser.find('.thankyoumessage').text().match(/:\s*(\S+)/) if(@browser.first(conf_num_locator.css))
   #        end
   #      end
   #      # TODO add better error handling here!
   #      if(@browser.first('.errorform'))
   #        errortext = @browser.first('.errorform').text()
   #        if(errortext.include?('Please enter passwords that match each other'))
   #          raise PasswordMatchException.new('"Please enter passwords that match each other" issue appeared')
   #        end
   #      end

   #      raise "Order Placement Failed" if confirmation_num.nil? || confirmation_num == 'N/A'
   #    rescue => e
   #      timeout += 1
   #      if(timeout < 3)
   #        check_if_page_ready
   #        js_exec('window.scrollBy(-1000,0)')
   #        js_exec('window.scrollBy(500,0)')
   #        click_if_exists(:css, '#contYourOrder') if @browser.first(:css, '#contYourOrder')          
   #        #Block added to expand the first contact mobile page - 01132016 ssankara - next 4 lines
   #        if(@browser.first('.more-less'))
   #          click_if_exists(:css, '.more-less')
   #          if(@browser.first('.more-less .plus'))
   #            click_if_exists(:css, '.more-less .plus')
   #          end
   #        end

   #        js_exec('window.scrollBy(-1000,0)')
   #        if(@campaign_configuration['Brand'] == "Supersmile")
   #          close_popups
   #          click_if_exists(:css, '.OrderNowButton') if @browser.first(:css, '.OrderNowButton') # Supersmile Legacy Issue
   #          check_if_page_ready
   #          close_popups
   #        end
   #        check_if_page_ready
   #        sleep(3)
   #        check_if_page_ready
   #        retry
   #      end
   #      raise e
   #    end
   #    close_popups()
   #    return confirmation_num.captures.first
   #  end # of get_confirmation_number
  end
end
