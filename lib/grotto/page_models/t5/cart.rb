module T5
  class Cart < BasePage
    def initialize(campaign_configuration)
      super(campaign_configuration)
      @add_vitamin_btn = [
        '.vitaminProduct a.addtocartbtn'
      ]
      @remove_vitamin_btn = [
        '.remove_vitamin'
      ]

      @test_data = {
        'email' =>              campaign_configuration['ConfEmailOverride'],
        'phone' =>              '9999999999',
        'first_name' =>         'Digital',
        'last_name' =>          'Automation',
        'address' =>            '123 QATest Street',
        'city' =>               'Anywhere',
        'state' =>              'CA',
        'zip' =>                '90405',
        'credit_card_number' => '4111111111111111',
        'credit_card_month' =>  '7',
        'credit_card_year' =>   '2019',
      }
    end

    def current_shipping_cost
      locators = GRDatabase.get_all_locators('cart', 'all', 'current_shipping_cost')
      locators.each do |locator|
        shipping_element = @browser.first(locator.css, :visible => false)
        if shipping_element
          ship_cost = shipping_element.text().scan(@price_regex).first
          ship_cost = "0.00" if shipping_element.text().include?('FREE SHIPPING') #ssankara - Adding the lines to check when the value is a Text
          if ship_cost
            return ship_cost            
          end
        end
      end
      return 'Not Found'
    end

    def vitamin_language
      locators = GRDatabase.get_all_locators('cart', 'all', 'vitamin_language')
      locators.each do |locator|
        vitamin_element = @browser.first(locator.css)
        if vitamin_element
          return vitamin_element.text()
        end
      end
      return 'Not Found'
    end

    def vitamin_title
      locators = GRDatabase.get_all_locators('cart', 'all', 'vitamin_title')
      locators.each do |locator|
        vitamin_element = @browser.first(locator.css)
        if vitamin_element
          return vitamin_element.text()
        end
      end
      return 'Not Found'
    end

    def check_sas_kit_name(name)
      locators = GRDatabase.get_all_locators('cart', 'all', 'sas_kit_name')

      locators.each do |locator|
        kit_names_elements = @browser.all(locator.css)
        kit_names_elements.each do |element|
          if element.text.downcase.include?(name.downcase)

          else
            return "Incorrect"
          end
        end
      end

      return "Correct"
    end

    def sas_kit_name
      list = []
      locators = GRDatabase.get_all_locators('cart', 'all', 'sas_kit_name')
      locators.each do |locator|
        kit_names_elements = @browser.all(locator.css)
        kit_names_elements.each do |element|
          list.push element.text
        end
      end

      return list
    end

    def quantity
      locators = GRDatabase.get_all_locators('cart', 'all', 'quantity')
      locators.each do |locator|
        quantity_element = @browser.first(locator.css)
        if quantity_element
          return quantity_element.value
        end
      end
      return nil
    end

    def continuity(offer)
      costxthree = offer['ContinuitySH']
      if(costxthree.include?('month') || costxthree.include?('3x') || offer['SupplySize'] == '90')
        
        cost = costxthree.scan(@price_regex).first.to_s
        if(cart_description.downcase.include?('per month'))
          cost = (cost.gsub('$','').to_f / 3).to_s
        end
      else
        cost = (costxthree.gsub('$','').to_f / 3).to_s
      end
      #binding.pry
      return cart_description.include?(cost).to_s
    end
    

    def vitamin_pricing
      vitamin_locators = GRDatabase.get_all_locators('cart', 'all', 'vitamin_pricing')
      vitamin_locators.each do |locator|
        get_value do
          vit_pricing_element = @browser.first(locator.css)
          if vit_pricing_element
            vitamin_pricing_string = vit_pricing_element.text()
            return vitamin_pricing_string.scan(@price_regex).first
          end
        end
      end
      return nil
    end

    def shipping(type)
      begin
        begin
          get_value do
            price_element = @browser.first("option[value='#{type}']", :visible => false)
            price_string = price_element.base.all_text().scan(@price_regex).first
          end
        rescue NoMethodError => e
          if(@browser.current_url.include?('supersmile') && type == 'Standard')
            return current_shipping_cost 
          else
            raise e
          end
        end
      rescue => e
        Rails.logger.info e.message
        return nil
      end
    end

    def check_sas_pricing(price)
      # get all elements for price
      wrong_prices = []
      price_locators = GRDatabase.get_all_locators('cart', 'all', 'check_sas_pricing')
      price_locators.each do |price_locator|
        price_fields = @browser.all(:css, price_locator.css)
        price_fields.each do |field|
          if field.text().include?(price)
            # Do nothing
          else
            wrong_prices.push(field.text())
          end
        end
      end
      if wrong_prices.empty?
        return nil
      else
        return wrong_prices
      end
    end

    def check_sas_prices()
      # get all elements for price
      prices = []
      price_locators = GRDatabase.get_all_locators('cart', 'all', 'check_sas_pricing')
      price_locators.each do |price_locator|
        price_fields = @browser.all(:css, price_locator.css)
        price_fields.each do |field|
            prices.push(field.text())
        end
      end
      return prices
    end


    def subtotal_price
      pricing_locators = GRDatabase.get_all_locators('cart', 'all', 'subtotal_price')
      pricing_locators.each do |locator|
        get_value do
          price_element = @browser.first(locator.css)
          if price_element
            price_string = price_element.text().strip().scan(@price_regex).first
            return price_string
          end
        end
      end
      return nil
    end

    def total_pricing
      pricing_locators = GRDatabase.get_all_locators('cart', 'all', 'total_pricing')
      pricing_locators.each do |locator|
        get_value do
          price_element = @browser.first(locator.css)
          if price_element
            price_string = price_element.text().strip().scan(@price_regex).first
            return price_string
          end
        end
      end
      return nil
    end

    def cart_title
      @cart_title_locators = GRDatabase.get_all_locators('cart', 'all', 'cart_title')
      @cart_title_locators.each do |cart_title_locator|
        get_value do
          cart_title_element = @browser.first(cart_title_locator.css)
          if(cart_title_element)
            cart_title_string = cart_title_element.text().strip
            return cart_title_string
          end
        end
      end
      return nil
    end

    def cart_description
      @cart_description_locators = GRDatabase.get_all_locators('cart', 'all', 'cart_description')
      @cart_description_locators.each do |locator| 
        get_value do
          cart_description_element = @browser.first(locator.css)
          if(cart_description_element)
            cart_description_string = cart_description_element.text().strip
            return cart_description_string
          end
        end
      end
      return nil
    end
    def upsell_locators
      Locator.where(brand: 'all', offer: 'post purchase upsell') #for upsell open and close upgrade
    end

    def find_if_upsell()
      @upsell_locators = upsell_locators()

      # This check to be performed for upsell campaign only
      current_running_tests = TestSuites.where(:Campaign => campaign_configuration["grcid"], :Status => 'Running') #ActiveRecord relation

      current_running_tests.each do |current_test|
        if current_test.is_upsell 
          @upsell_locators.where(step: "upsellopen").each do |locator|
            catch_simple do
              @browser.first(:css, locator.css).click()
            end            
          end
          js_exec('window.scrollBy(-1000,0)')
          js_exec('window.scrollBy(500,0)')
            catch_simple do
              @browser.all('#contYourOrder').first.click()
            end          
            #catch all elements again
        else
          @upsell_locators.where(step: "upsellclose").each do |locator|
            catch_simple do
              @browser.first(:css, locator.css).click()
            end            
          end          
        end
      end      
    end

    def confirmation_page()
      page = Confirmation.new(@campaign_configuration)
      page.browser = @browser
      return page
    end

    # Adapts the module to a specific module type
    def adapt()
      template = @campaign_configuration["DesktopCartPageTemplate"]

      Rails.logger.info "template: #{template}"
      case template
      when 'DCC'
        page = CheckoutCart.new(@campaign_configuration)
      when 'DPC'
        # page = PlainCart.new(@campaign_configuration)
        page = InlineCart.new(@campaign_configuration)
      when 'DAC', 'MAC'
        page = AccordionCart.new(@campaign_configuration)
      when 'DSC', 'MSC'
        page = StepsCart.new(@campaign_configuration)
      when 'DMC'
        Rails.logger.info "UNIMPLEMENETED TEMPLATE: #{@campaign_configuration.cart} - Using 'DPC'"
        page = PlainCart.new(@campaign_configuration)
      when 'LegacyCart'
        page = LegacyCart.new(@campaign_configuration)
      when 'LegacyMobileCart', 'MMC', 'MPC'
        page = LegacyMobileCart.new(@campaign_configuration)
      when 'RealmTwo'
        page = RealmTwo.new(@campaign_configuration)
      when 'LegacyReclaimCart'
        page = LegacyReclaimCart.new(@campaign_configuration)
      when 'RealmTwoMobile'
        page = RealmTwoMobile.new(@campaign_configuration)
      when 'FlexCartTemplate'
        page = FlexCart.new(@campaign_configuration)
      else
        page = PlainCart.new(@campaign_configuration)
      end
      page.browser = @browser
      return page
    end #end of adapt method

    # Completes the order purchase form for the cart module
    def place_order()
      # js_exec('window.scrollBy(-1000,0)')
      js_exec('window.scrollBy(0,1000)')
      self.email              = @test_data['email']
      self.phone              = @test_data['phone']
      self.first_name         = @test_data['first_name']
      self.last_name          = @test_data['last_name']
      self.address            = @test_data['address']
      self.city               = @test_data['city']
      self.state              = @test_data['state']
      self.zip                = @test_data['zip']
      js_exec('window.scrollBy(-1000,0)')
      self.credit_card_number = @test_data['credit_card_number']
      self.credit_card_month  = @test_data['credit_card_month']
      self.credit_card_year   = @test_data['credit_card_year']
      agreetoterms()
      return confirmation_page
    end # end of place_order

    def add_vitamin()
      if(@browser.first('.vitaminProduct a.addtocartbtn'))
        timeout = 0;
        begin
          click(:css, '.vitaminProduct a.addtocartbtn')
          @browser.find('.remove_vitamin')
        rescue => e
          timeout += 1
          retry if timeout < 2
        end
      else
        if(@browser.first('.add-vitamin'))
        timeout = 0;
        begin
          click(:css, '.add-vitamin')
          @browser.find('.remove-vitamin')
        rescue => e
          timeout += 1
          retry if timeout < 2
        end
      else
        return nil
      end
      end
    end # end of add vitamin method

    def offercode()
      # Adding for core ID - block in rescue
      begin
        get_value do
         return @browser.first(:css, '.coreid', :visible => false).value
        end
      rescue => e
        get_value do
         return @browser.first(:css, '.offerCodeID', :visible => false).value
        end
      end      
    end

    def vitamin_offercode()
      if(@browser.first(:css, '.coreidCY', :visible => false) && (@browser.first('.remove_vitamin') || @browser.first('.remove-vitamin')))
        get_value do
          return @browser.first(:css, '.coreidCY', :visible => false).value
        end
      else
        return "N/A"
      end
    end # end of vitamin method

    def submit_order()
      #Rails.logger.info 'Submitting Order'
      begin
        begin
          click(:css, '#contYourOrder');
        rescue
          js_exec('window.scrollBy(-1000,0)')
          js_exec('window.scrollBy(500,0)')
          begin
            click(:css, '#contYourOrder');
          rescue => e
            @browser.first(:css, '#contYourOrder').click() if @browser.first(:css, '#contYourOrder')
            @browser.first(:css, '#contYourOrder').click() if @browser.first(:css, '#contYourOrder')
            @browser.first(:css, '#contYourOrder').click() if @browser.first(:css, '#contYourOrder')
          end
        end
      rescue => e
        (1..2).each do # iterate twice through loop
          sleep(1)
          catch_simple do
            @browser.all('#contYourOrder').first.click()
          end
          catch_simple do
            @browser.all('#contYourOrder').last.click()
          end
        end
      end
      find_if_upsell() 
      return confirmation_page()
    end # of submit_order()

    def email
      email_element = @browser.find(@locators['email']['type'].to_sym, @locators['email']['selector'])
      return email_element.value
    end

    def email=(email_address)
      email_element = @browser.find(@locators['email']['type'].to_sym, @locators['email']['selector'])
      setElement(email_element, email_address)
    end

    def email_conf
      email_element = @browser.find(@locators['email_confirmation']['type'].to_sym, @locators['email_confirmation']['selector'])
      return email_element.value
    end

    def email_conf=(email_address)
      email_element = @browser.find(@locators['email_confirmation']['type'].to_sym, @locators['email_confirmation']['selector'])
      setElement(email_element, email_address)
    end

    def phone
      phone_element1 = @browser.find(@locators['phone1']['type'].to_sym, @locators['phone1']['selector'])
      phone_element2 = @browser.find(@locators['phone2']['type'].to_sym, @locators['phone2']['selector'])
      phone_element3 = @browser.find(@locators['phone3']['type'].to_sym, @locators['phone3']['selector'])
      return phone_element1.value + phone_element2.value + phone_element3.value
    end

    def phone=(number)
      phone_element1 = @browser.find(@locators['phone1']['type'].to_sym, @locators['phone1']['selector'])
      setElement(phone_element1, number[0..2])
      phone_element2 = @browser.find(@locators['phone2']['type'].to_sym, @locators['phone2']['selector'])
      setElement(phone_element2, number[3..5])
      phone_element3 = @browser.find(@locators['phone3']['type'].to_sym, @locators['phone3']['selector'])
      setElement(phone_element3, number[6..9])
    end

    def first_name
      name_element = @browser.find(@locators['firstname']['type'].to_sym, @locators['firstname']['selector'])
      return name_element.value
    end

    def first_name=(name)
      name_element = @browser.find(@locators['firstname']['type'].to_sym, @locators['firstname']['selector'])
      setElement(name_element, name)
    end

    def last_name
      name_element = @browser.find(@locators['lastname']['type'].to_sym, @locators['lastname']['selector'])
      return name_element.value
    end

    def last_name=(name)
      name_element = @browser.find(@locators['lastname']['type'].to_sym, @locators['lastname']['selector'])
      setElement(name_element, name)
    end

    def address
      address_element = @browser.find(@locators['billAddress']['type'].to_sym, @locators['billAddress']['selector'])
      return address_element.value
    end

    def address=(address)
      address_element = @browser.find(@locators['billAddress']['type'].to_sym, @locators['billAddress']['selector'])
      setElement(address_element, address)
    end

    def address2
      address_element = @browser.find(@locators['billAddress2']['type'].to_sym, @locators['billAddress2']['selector'])
      return address_element.value
    end

    def address2=(address)
      address_element = @browser.find(@locators['billAddress2']['type'].to_sym, @locators['billAddress2']['selector'])
      setElement(address_element, address)
    end

    def city
      address_element = @browser.find(@locators['billCity']['type'].to_sym, @locators['billCity']['selector'])
      return address_element.value
    end

    def city=(city)
      address_element = @browser.find(@locators['billCity']['type'].to_sym, @locators['billCity']['selector'])
      setElement(address_element, city)
    end

    def state
      address_element = @browser.find(@locators['billState']['type'].to_sym, @locators['billState']['selector'])
      return address_element.value
    end

    def state=(state)
      address_element = @browser.find(@locators['billState']['type'].to_sym, @locators['billState']['selector'])
      dropdownselect(address_element, state)
    end

    def zip
      zip_element = @browser.find(@locators['billZip']['type'].to_sym, @locators['billZip']['selector'])
      return zip_element.value
    end

    def zip=(zip)
      zip_element = @browser.find(@locators['billZip']['type'].to_sym, @locators['billZip']['selector'])
      setElement(zip_element, zip)
    end

    def credit_card_number
      creditCardNumber_element = @browser.find(@locators['creditCardNumber']['type'].to_sym, @locators['creditCardNumber']['selector'])
      return creditCardNumber_element.value
    end

    def credit_card_number=(creditCardNumber)
      creditCardNumber_element = @browser.find(@locators['creditCardNumber']['type'].to_sym, @locators['creditCardNumber']['selector'])
      setElement(creditCardNumber_element, creditCardNumber)
    end

    def credit_card_month
      creditCardMonth_element = @browser.find(@locators['creditCardMonth']['type'].to_sym, @locators['creditCardMonth']['selector'])
      return creditCardMonth_element.value
    end

    def credit_card_month=(creditCardMonth)
      creditCardMonth_element = @browser.find(@locators['creditCardMonth']['type'].to_sym, @locators['creditCardMonth']['selector'])
      begin
        dropdownselect(creditCardMonth_element, creditCardMonth)
      rescue => e
        Rails.logger.info e.message
        Rails.logger.info e.backtrace
        begin
          dropdownselect(creditCardMonth_element, "January")
        rescue => e
          return
        end
      end
    end

    def credit_card_year
      creditCardYear_element = @browser.find(@locators['creditCardYear']['type'].to_sym, @locators['creditCardYear']['selector'])
      return creditCardYear_element.value
    end

    def credit_card_year=(creditCardYear)
      creditCardYear_element = @browser.find(@locators['creditCardYear']['type'].to_sym, @locators['creditCardYear']['selector'])
      dropdownselect(creditCardYear_element, creditCardYear)
    end

    def agreetoterms
      agreetoterms_element = @browser.find(@locators['agreetoterms']['type'].to_sym, @locators['agreetoterms']['selector'])
      return agreetoterms_element.value
    end

    def agreetoterms(state = true)
      agreetoterms_element = @browser.find(@locators['agreetoterms']['type'].to_sym, @locators['agreetoterms']['selector'])
      checkBox(agreetoterms_element, state)
    end

  end # end of Cart Class

  class InlineCart < Cart
    def offercode()
      # Adding for core ID - block in rescue
      begin
        if(@browser.has_selector?(:css, '.coreid', :visible => false))
          offercode = @browser.first(:css, '.coreid', :visible => false).text
        elsif(@browser.has_selector?(:css, '.offerCodeID', :visible => false))
          offercode = @browser.first(:css, '.offerCodeID', :visible => false).text
        end
        return offercode
      rescue => e
        
      end      
    end

    def grcid
      begin
        super(javascript_variable: 'app.omniMap.CampaignID')
      rescue => e

      end
    end

    def quantity
      begin
        puts "first"
        puts @browser.has_selector?(:xpath, './/div[@class="select-kit-qty"]/select[@class="quantityselector ctrackingSelect"]')
        puts "second"
        puts @browser.has_selector?(:xpath, './/select[@id="quantity_0"]')
        quantity_text = @browser.find(:xpath, './/div[@class="select-kit-qty"]/select[@class="quantityselector ctrackingSelect"]').find("option[selected]").text
        puts "quantity_text"
        puts quantity_text
        quantity_array = quantity_text.split(' ')
        puts quantity_array
        return quantity_array[0]
      rescue => e

      end      
    end

    def cart_title
      begin
        name1 = @browser.find(:css, '.cartOverlayBg .prodWrapper .tablerow .detailscolumn div.name').text
        return name1
      rescue => e

      end
    end

    def cart_description
      begin
        @browser.find(:xpath, './/div[@class="shortDescription"]').text
      rescue => e

      end
    end

    def total_pricing
      begin
        @browser.find(:xpath, './/div[@id="orderTotal_1"]').text
      rescue => e

      end
    end

    def subtotal_price
      begin
        subtotal_text = @browser.find(:xpath, './/div[@id="subTotal"]').text
        subtotal_array = subtotal_text.split(' ')
        puts subtotal_array
        return subtotal_array[0]
      rescue => e

      end
    end

    def check_sas_pricing(price)
      wrong_prices = []
      price_locator_text = @browser.find(:xpath, './/div[@id="subTotal"]').text
      if price_locator_text.include? (price)

      else
        wrong_prices.push(price_locator_text)
      end
      if wrong_prices.empty?
        return nil
      else
        return wrong_prices
      end
    end

    def check_sas_prices()
      # get all elements for price
      prices = []
      subtotal_locator_text = @browser.find(:xpath, './/div[@id="subTotal"]').text
      prices.push(subtotal_locator_text)
      return prices
    end

    def shipping(type)
      begin
        begin
          get_value do
            price_element = @browser.first("option[value='#{type}']", :visible => false)
            price_string = price_element.base.all_text().scan(@price_regex).first
          end
        rescue NoMethodError => e
          
        end
      rescue => e
        Rails.logger.info e.message
        return nil
      end
    end

    def current_shipping_cost
      begin
        shipping_text = @browser.find(:xpath, './/select[@id="dwfrm_cart_shippingMethodID"]').find("option[selected]").text
        ship_cost = shipping_text.scan(@price_regex).first
        ship_cost = "0.00" if ((shipping_text.include?('FREE SHIPPING')) || (shipping_text.include?('0.00')))
        if ship_cost
          return ship_cost
        end
        return 'Not Found'
      rescue => e

      end
    end

    def continuity(offer)
      contsh = offer['ContinuitySH']
      return cart_description.include?(contsh).to_s
    end

    def place_order(email)
      puts "placing orders in product cart"
      fill_details = Locator.where(brand: 'all', offer: 'productorderlocators')

      Rails.logger.info "Placing product order"

      fill_details.where(step: "email").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => (email))
          # @browser.fill_in(locator.css, :with => 'ozeddedud-9125@yopmail.com')
          
        rescue => e

        end
      end

      fill_details.where(step: "fullphone").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => '9999999999')
        rescue => e

        end
      end

      Rails.logger.info "filling out billing details"

      fill_details.where(step: "firstname").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => 'Digital')
        rescue => e

        end
      end

      fill_details.where(step: "lastname").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => 'Automation')
        rescue => e

        end
      end

      fill_details.where(step: "address1").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => '123 QATest Street')
        rescue => e

        end
      end

      fill_details.where(step: "city").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => 'Anywhere')
        rescue => e

        end
      end

      fill_details.where(step: "state").each do |locator|
        begin
          @browser.find_field(locator.css).find("option[value='CA']").select_option
        rescue => e

        end
      end

      fill_details.where(step: "zip").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => '90405')
        rescue => e

        end
      end

      Rails.logger.info "filling out credit card"

      fill_details.where(step: "ccnumber").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => '4111111111111111')
        rescue => e

        end
      end

      fill_details.where(step: "ccmonth").each do |locator|
        begin
          @browser.find_field(locator.css).find("option[value='10']").select_option
        rescue => e
          
        end
      end

      fill_details.where(step: "paymentmethod").each do |locator|
        begin
          @browser.find_field(locator.css).select('Visa')
        rescue => e

        end
      end

      fill_details.where(step: "ccyear").each do |locator|
        begin
          @browser.find_field(locator.css).find("option[value='2018']").select_option
        rescue => e

        end
      end

      fill_details.where(step: "agreecheck").each do |locator|
        begin
          @browser.find_field(locator.css).click()
        rescue => e
         
        end
        begin
          @browser.first(:css, locator.css, :visible => false).set(true)
        rescue => e

        end
      end
    end
  end

  class CheckoutCart < Cart
    def offercode
      begin
        offercode_array = []
        locators = @browser.all(:xpath, './/input[@id="productIdForUpdateQty"]', :visible => false)
        locators.each do |offercode|
          offercode_array.push(offercode.value)
        end
        offercode_string = offercode_array.join(';')
        return offercode_string
      rescue => e
        
      end      

    end

    def grcid
      begin
        super(javascript_variable: 'app.omniMap.CampaignID')
      rescue => e

      end
    end

    def quantity
      begin
        puts "hi quantity"
        total_quantity = 0
        total_quantity = total_quantity.to_i
        locators = @browser.all(:xpath, './/div[@class="select-kit-qty"]/select[@name="1.0"]')
        locators.each do |quantity|
          puts quantity
          quantity_value = quantity.find("option[selected]").text
          puts quantity_value
          quantity_value = quantity_value.to_i
          total_quantity += quantity_value
          puts total_quantity
        end
        return total_quantity
        # quantity_text = @browser.find(:xpath, './/select[@id="quantity_0"]').find("option[selected]").text
        # quantity_array = quantity_text.split(' ')
        # puts quantity_array
        # return quantity_array[0]
      rescue => e

      end      
    end   

    def cart_title
      begin
        puts "hi product"
        title_array = []
        locators = @browser.all(:xpath, './/div[@class="offer-code-desc"]')
        puts locators
        puts "locators"
        # title_array.push(locators.text)
        locators.each do |title|
          puts title
          title_array.push(title.text)
        end
        title_string = title_array.join(';')
        return title_string
        # @browser.find(:xpath, './/div[@class="offer-code-desc"]').text
      rescue => e

      end
    end

    def check_sas_kit_name(name)
      name_array = []
      locators = @browser.all(:xpath, './/div[@class="offer-code-desc"]')
      locators.each do |title|
        name_array.push(title.text)
      end
      kit_element_text = name_array.join(';')
      if kit_element_text.downcase.include?(name.downcase)

      else
        return "Incorect"
      end
      return "Correct"
    end

    def cart_description
      begin
        @browser.find(:xpath, './/div[@class="core-product-description column"]').text
      rescue => e

      end
    end

    def total_pricing
      begin
        @browser.find(:xpath, './/div[@id="totalorderprice"]/span').text
      rescue => e

      end
    end

    def subtotal_price
      begin
        @browser.find(:xpath, './/div[@id="subTotal"]').text
      rescue => e

      end
    end

    def check_sas_pricing(price)
      wrong_prices = []
      price_locator_text = @browser.find(:xpath, './/div[@id="subTotal"]').text
      if price_locator_text.include? (price)

      else
        wrong_prices.push(price_locator_text)
      end
      if wrong_prices.empty?
        return nil
      else
        return wrong_prices
      end
    end

    def check_sas_prices()
      # get all elements for price
      prices = []
      subtotal_locator_text = @browser.find(:xpath, './/div[@id="subTotal"]').text
      prices.push(subtotal_locator_text)
      return prices
    end

    def shipping(type)
      begin
        shipping_type = @browser.find(:xpath, './/select[@id="dwfrm_cart_shippingMethodID"]').find("option[selected]").value
        if((type == 'Standard') && (shipping_type == 'Standard-Single-Products'))
          type = 'Standard-Single-Products'
        end
        begin
          get_value do
            price_element = @browser.first("option[value='#{type}']", :visible => false)
            price_string = price_element.base.all_text().scan(@price_regex).first
          end
        rescue NoMethodError => e
          
        end
      rescue => e
        Rails.logger.info e.message
        return nil
      end
    end

    def continuity(offer)
      contsh = offer['ContinuitySH']
      description = cart_description
      if (description == nil)
        return true
      else
        return cart_description.include?(contsh).to_s
      end
    end

    def current_shipping_cost
      begin
        shipping_text = @browser.find(:xpath, './/select[@id="dwfrm_cart_shippingMethodID"]').find("option[selected]").text
        ship_cost = shipping_text.scan(@price_regex).first
        ship_cost = "0.00" if ((shipping_text.include?('FREE SHIPPING')) || (shipping_text.include?('0.00')))
        if ship_cost
          return ship_cost
        end
        return 'Not Found'
      rescue => e

      end
    end

    def submit_order
      begin
        @browser.find(:xpath, './/button[@id="contYourOrder"]').click()
      rescue => e

      end
      page = Confirmation.new(@campaign_configuration)
      page.browser = @browser
      return page
    end

    def place_order(email)
      puts "placing orders in product cart"
      fill_details = Locator.where(brand: 'all', offer: 'productorderlocators')

      Rails.logger.info "Placing product order"

      fill_details.where(step: "email").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => (email))
          # @browser.fill_in(locator.css, :with => 'ozeddedud-9125@yopmail.com')
          
        rescue => e

        end
      end

      fill_details.where(step: "fullphone").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => '9999999999')
        rescue => e

        end
      end

      Rails.logger.info "filling out billing details"

      fill_details.where(step: "firstname").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => 'Digital')
        rescue => e

        end
      end

      fill_details.where(step: "lastname").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => 'Automation')
        rescue => e

        end
      end

      fill_details.where(step: "address1").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => '123 QATest Street')
        rescue => e

        end
      end

      fill_details.where(step: "city").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => 'Anywhere')
        rescue => e

        end
      end

      fill_details.where(step: "state").each do |locator|
        begin
          @browser.find_field(locator.css).find("option[value='CA']").select_option
        rescue => e

        end
      end

      fill_details.where(step: "zip").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => '90405')
        rescue => e

        end
      end

      Rails.logger.info "filling out credit card"

      fill_details.where(step: "ccnumber").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => '4111111111111111')
        rescue => e

        end
      end

      fill_details.where(step: "ccmonth").each do |locator|
        begin
          @browser.find_field(locator.css).find("option[value='10']").select_option
        rescue => e
          
        end
      end

      fill_details.where(step: "paymentmethod").each do |locator|
        begin
          @browser.find_field(locator.css).select('Visa')
        rescue => e

        end
      end

      fill_details.where(step: "ccyear").each do |locator|
        begin
          @browser.find_field(locator.css).find("option[value='2018']").select_option
        rescue => e

        end
      end

      fill_details.where(step: "agreecheck").each do |locator|
        begin
          @browser.find_field(locator.css).click()
        rescue => e
         
        end
        begin
          @browser.first(:css, locator.css, :visible => false).set(true)
        rescue => e

        end
      end
    end
  end

  class PlainCart < Cart
    def initialize(campaign_configuration)
      super(campaign_configuration)
      locators = GRDatabase.get_orderform('T4').first
                @locators = {}
        @locators = {
          'email'             => {'type' => 'css', 'selector' => locators['email']},
          'phone'            => {'type' => 'css', 'selector' => locators['phone']},
          'phone1'            => {'type' => 'css', 'selector' => locators['phone1']},
          'phone2'            => {'type' => 'css', 'selector' => locators['phone2']},
          'phone3'            => {'type' => 'css', 'selector' => locators['phone3']},
          'firstname'         => {'type' => 'css', 'selector' => locators['firstname']},
          'lastname'          => {'type' => 'css', 'selector' => locators['lastname']},
          'billAddress'       => {'type' => 'css', 'selector' => locators['billAddress']},
          'billAddress2'      => {'type' => 'css', 'selector' => locators['billAddress2']},
          'billCity'          => {'type' => 'css', 'selector' => locators['billCity']},
          'billState'         => {'type' => 'css', 'selector' => locators['billState']},
          'billZip'           => {'type' => 'css', 'selector' => locators['billZip']},
          'creditCardNumber'  => {'type' => 'css', 'selector' => locators['creditCardNumber']},
          'creditCardMonth'   => {'type' => 'css', 'selector' => locators['creditCardMonth']},
          'creditCardYear'    => {'type' => 'css', 'selector' => locators['creditCardYear']},
          'agreetoterms'      => {'type' => 'css', 'selector' => locators['agreetoterms']},
        } # TODO Move to database
    end
  end # of PlainCart Class

  class RealmTwo < PlainCart
    def initialize(campaign_configuration)
      super(campaign_configuration)
      locators = GRDatabase.get_orderform('Realm2').first
        @locators = {}
        @locators = {
          'email'             => {'type' => 'css', 'selector' => locators['email']},
          'phone'            => {'type' => 'css', 'selector' => locators['phone']},
          'phone1'            => {'type' => 'css', 'selector' => locators['phone1']},
          'phone2'            => {'type' => 'css', 'selector' => locators['phone2']},
          'phone3'            => {'type' => 'css', 'selector' => locators['phone3']},
          'firstname'         => {'type' => 'css', 'selector' => locators['firstname']},
          'lastname'          => {'type' => 'css', 'selector' => locators['lastname']},
          'billAddress'       => {'type' => 'css', 'selector' => locators['billAddress']},
          'billAddress2'      => {'type' => 'css', 'selector' => locators['billAddress2']},
          'billCity'          => {'type' => 'css', 'selector' => locators['billCity']},
          'billState'         => {'type' => 'css', 'selector' => locators['billState']},
          'billZip'           => {'type' => 'css', 'selector' => locators['billZip']},
          'creditCardNumber'  => {'type' => 'css', 'selector' => locators['creditCardNumber']},
          'creditCardMonth'   => {'type' => 'css', 'selector' => locators['creditCardMonth']},
          'creditCardYear'    => {'type' => 'css', 'selector' => locators['creditCardYear']},
          'agreetoterms'      => {'type' => 'css', 'selector' => locators['agreetoterms']},
        } # TODO Move to database
        @locators['email_confirmation'] = {'type' => 'css', 'selector' => '#emailConfirmation'}
    end

    def offercode()
      get_value do
        return @browser.first(:css, '.offerCodeID').text().strip
      end
    end

    def grcid()
      super(javascript_variable: 'app.omniMap.CampaignID')
    end

    def vitamin_offercode()
      if(@browser.first(:css, '.upsell-remove-from-cart', :visible => false))
        get_value do
          return @browser.first(:css, '.upsell-remove-from-cart', :visible => false)['data-pid']
        end
      else
        return "N/A"
      end
    end # end of vitamin method

    def add_vitamin()
      vitamin_locator = '.upsell-add-to-cart a.add-to-cart'
      if(@browser.first(vitamin_locator))
        timeout = 0;
        begin
          click(:css, vitamin_locator)
          @browser.find('.upsell-remove-from-cart')
        rescue => e
          timeout += 1
          retry if timeout < 2
        end
      else
        if(@browser.first('.add-vitamin'))
        timeout = 0;
        begin
          click(:css, '.add-vitamin')
          @browser.find('.remove-vitamin')
        rescue => e
          timeout += 1
          retry if timeout < 2
        end
      else
        return nil
      end
      end
    end # end of add vitamin method
  end


  class StepsCart < Cart
    # Completes the order purchase form for the cart module
    def place_order()
      # TODO add transitions for steps cart
      self.email              = @test_data['email']
      self.phone              = @test_data['phone']
      self.first_name         = @test_data['first_name']
      self.last_name          = @test_data['last_name']
      self.address            = @test_data['address']
      self.city               = @test_data['city']
      self.state              = @test_data['state']
      self.zip                = @test_data['zip']
      self.credit_card_number = @test_data['credit_card_number']
      self.credit_card_month  = @test_data['credit_card_month']
      self.credit_card_year   = @test_data['credit_card_year']
      agreetoterms()
      return confirmation_page
    end # end of place_order
  end # of StepsCart Class

  class AccordionCart < Cart
    # Completes the order purchase form for the cart module
    def place_order()
      # TODO add transitions for accordion cart
      self.email              = @test_data['email']
      self.phone              = @test_data['phone']
      self.first_name         = @test_data['first_name']
      self.last_name          = @test_data['last_name']
      self.address            = @test_data['address']
      self.city               = @test_data['city']
      self.state              = @test_data['state']
      self.zip                = @test_data['zip']
      self.credit_card_number = @test_data['credit_card_number']
      self.credit_card_month  = @test_data['credit_card_month']
      self.credit_card_year   = @test_data['credit_card_year']
      agreetoterms()
      return confirmation_page
    end # end of place_order
  end # of AccordionCart Class

  class LegacyCart < PlainCart
    def initialize(campaign_configuration)
      super(campaign_configuration)
      locators = GRDatabase.get_orderform('Legacy').first
        @locators = {}
        @locators = {
          'email'             => {'type' => 'css', 'selector' => locators['email']},
          'phone'            => {'type' => 'css', 'selector' => locators['phone']},
          'phone1'            => {'type' => 'css', 'selector' => locators['phone1']},
          'phone2'            => {'type' => 'css', 'selector' => locators['phone2']},
          'phone3'            => {'type' => 'css', 'selector' => locators['phone3']},
          'firstname'         => {'type' => 'css', 'selector' => locators['firstname']},
          'lastname'          => {'type' => 'css', 'selector' => locators['lastname']},
          'billAddress'       => {'type' => 'css', 'selector' => locators['billAddress']},
          'billAddress2'      => {'type' => 'css', 'selector' => locators['billAddress2']},
          'billCity'          => {'type' => 'css', 'selector' => locators['billCity']},
          'billState'         => {'type' => 'css', 'selector' => locators['billState']},
          'billZip'           => {'type' => 'css', 'selector' => locators['billZip']},
          'creditCardNumber'  => {'type' => 'css', 'selector' => locators['creditCardNumber']},
          'creditCardMonth'   => {'type' => 'css', 'selector' => locators['creditCardMonth']},
          'creditCardYear'    => {'type' => 'css', 'selector' => locators['creditCardYear']},
          'agreetoterms'      => {'type' => 'css', 'selector' => locators['agreetoterms']},
        } # TODO Move to database
        @locators['email_confirmation'] = {'type' => 'css', 'selector' => '#emailConfirmation'}
    end

    def submit_order()
      #Rails.logger.info 'Submitting Order'
      click(:css, '.OrderNowButton');
      return confirmation_page()
    end # of submit_order()


    def phone=(number)
      phone_element1 = @browser.find(@locators['phone']['type'].to_sym, @locators['phone']['selector'])
      setElement(phone_element1, number)
    end

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

    def offercode()
      get_value do
        code = @browser.first(:css, '.qtySelector')
        return code['id']
      end
    end

    def place_order()
      Rails.logger.info "Placing order"
      close_popups
      begin
        self.email              = @test_data['email']
        self.email_conf         = @test_data['email']
        self.phone              = @test_data['phone']
        self.first_name         = @test_data['first_name']
      rescue => e
        close_popups
        self.email              = @test_data['email']
        self.email_conf         = @test_data['email']
        self.phone              = @test_data['phone']
        self.first_name         = @test_data['first_name']
      end
      self.last_name          = @test_data['last_name']
      self.address            = @test_data['address']
      self.city               = @test_data['city']
      close_popups
      self.state              = @test_data['state']

      @browser.windows.each do |window|
        window.close if(window.current? == false)
      end
      self.zip                = @test_data['zip']
      timeout = 0
      begin
        self.credit_card_number = @test_data['credit_card_number']

        begin
          self.credit_card_month  = @test_data['credit_card_month']
        rescue

        end

        begin
          self.credit_card_year   = @test_data['credit_card_year']
        rescue

        end
        agreetoterms()
      rescue => e 
        timeout += 1
        e.display
        retry if(timeout < 5)
      end

      return confirmation_page
    end # end of place_order

    def credit_card_number=(creditCardNumber)
      spinner = nil
      locators = [
        '#paymentMethodSelect',
        '#paymentMethod',
      ]
      locators.each do |locator|
        spinner = @browser.find(locator) if @browser.first(locator)
      end
      begin
        dropdownselect(spinner, 'Visa')
      rescue

      end
      super(creditCardNumber)
    end
  end# of LegacyCart Class

  class LegacyReclaimCart < LegacyCart
    def phone
      phone_element1 = @browser.find(@locators['phone1']['type'].to_sym, @locators['phone1']['selector'])
      phone_element2 = @browser.find(@locators['phone2']['type'].to_sym, @locators['phone2']['selector'])
      phone_element3 = @browser.find(@locators['phone3']['type'].to_sym, @locators['phone3']['selector'])
      return phone_element1.value + phone_element2.value + phone_element3.value
    end

    def offercode()
      get_value do
        return @browser.first(:css, '.coreid', :visible => false).value
      end
    end

    def phone=(number)
      phone_element1 = @browser.find(@locators['phone1']['type'].to_sym, @locators['phone1']['selector'])
      setElement(phone_element1, number[0..2])
      phone_element2 = @browser.find(@locators['phone2']['type'].to_sym, @locators['phone2']['selector'])
      setElement(phone_element2, number[3..5])
      phone_element3 = @browser.find(@locators['phone3']['type'].to_sym, @locators['phone3']['selector'])
      setElement(phone_element3, number[6..9])
    end

    def initialize(campaign_configuration)
      super(campaign_configuration)
      locators = GRDatabase.get_orderform('LegacyReclaim').first
        @locators = {}
        @locators = {
          'email'             => {'type' => 'css', 'selector' => locators['email']},
          'phone'            => {'type' => 'css', 'selector' => locators['phone']},
          'phone1'            => {'type' => 'css', 'selector' => locators['phone1']},
          'phone2'            => {'type' => 'css', 'selector' => locators['phone2']},
          'phone3'            => {'type' => 'css', 'selector' => locators['phone3']},
          'firstname'         => {'type' => 'css', 'selector' => locators['firstname']},
          'lastname'          => {'type' => 'css', 'selector' => locators['lastname']},
          'billAddress'       => {'type' => 'css', 'selector' => locators['billAddress']},
          'billAddress2'      => {'type' => 'css', 'selector' => locators['billAddress2']},
          'billCity'          => {'type' => 'css', 'selector' => locators['billCity']},
          'billState'         => {'type' => 'css', 'selector' => locators['billState']},
          'billZip'           => {'type' => 'css', 'selector' => locators['billZip']},
          'creditCardNumber'  => {'type' => 'css', 'selector' => locators['creditCardNumber']},
          'creditCardMonth'   => {'type' => 'css', 'selector' => locators['creditCardMonth']},
          'creditCardYear'    => {'type' => 'css', 'selector' => locators['creditCardYear']},
          'agreetoterms'      => {'type' => 'css', 'selector' => locators['agreetoterms']},
        } # TODO Move to database
        @locators['email_confirmation'] = {'type' => 'css', 'selector' => '#dwfrm_personinf_contact_emailconfirm'}
    end

    def submit_order()
      #Rails.logger.info 'Submitting Order'
      click_if_exists(:css, '#contYourOrder');
      return confirmation_page()
    end # of submit_order()

    def credit_card_number=(creditCardNumber)
      click_if_exists(:css, '#contYourOrder')
      creditCardNumber_element = @browser.find(@locators['creditCardNumber']['type'].to_sym, @locators['creditCardNumber']['selector'])
      setElement(creditCardNumber_element, creditCardNumber)
    end

  end

  class LegacyMobileCart < Cart
    def initialize(campaign_configuration)
      super(campaign_configuration)
      locators = GRDatabase.get_orderform('LegacyMobileCart').first
        @locators = {}
        @locators = {
          'email'             => {'type' => 'css', 'selector' => locators['email']},
          'phone'            => {'type' => 'css', 'selector' => locators['phone']},
          'phone1'            => {'type' => 'css', 'selector' => locators['phone1']},
          'phone2'            => {'type' => 'css', 'selector' => locators['phone2']},
          'phone3'            => {'type' => 'css', 'selector' => locators['phone3']},
          'firstname'         => {'type' => 'css', 'selector' => locators['firstname']},
          'lastname'          => {'type' => 'css', 'selector' => locators['lastname']},
          'billAddress'       => {'type' => 'css', 'selector' => locators['billAddress']},
          'billAddress2'      => {'type' => 'css', 'selector' => locators['billAddress2']},
          'billCity'          => {'type' => 'css', 'selector' => locators['billCity']},
          'billState'         => {'type' => 'css', 'selector' => locators['billState']},
          'billZip'           => {'type' => 'css', 'selector' => locators['billZip']},
          'creditCardNumber'  => {'type' => 'css', 'selector' => locators['creditCardNumber']},
          'creditCardMonth'   => {'type' => 'css', 'selector' => locators['creditCardMonth']},
          'creditCardYear'    => {'type' => 'css', 'selector' => locators['creditCardYear']},
          'agreetoterms'      => {'type' => 'css', 'selector' => locators['agreetoterms']},
        } # TODO Move to database
        @locators['email_confirmation'] = {'type' => 'css', 'selector' => '#dwfrm_personinf_contact_emailconfirm'}
    end
	
    def phone=(number)
      phone_element1 = @browser.find(@locators['phone']['type'].to_sym, @locators['phone']['selector'])
      setElement(phone_element1, number)
    end

    def credit_card_number=(creditCardNumber)
      spinner = nil
      locators = [
        '#paymentMethodSelect',
        '#paymentMethod',
        '#paymentMethodSelection'
      ]
      locators.each do |locator|
        spinner = @browser.find(locator) if @browser.first(locator)
      end

      dropdownselect(spinner, 'Visa')

      super(creditCardNumber)
    end
  end # of LegacyMobileCart Class

  class RealmTwoMobile < RealmTwo
    def phone=(number)
      phone_element1 = @browser.find(@locators['phone']['type'].to_sym, @locators['phone']['selector'])
      setElement(phone_element1, number)
    end
  end # of RealmTwoMobile Class

  class FlexCart < Cart
    @locat = nil
    def initialize(campaign_configuration)
      super(campaign_configuration)
      @locat = locators()
    end

    def locators
      Locator.where(brand: 'all', offer: 'orderplacementlocators')
    end

    def email=(email_address)
      @locat.where(step: "emailfield").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => email_address)
        rescue => e

        end
      end
    end


    def email_conf=(email_address)
      email_element = @browser.find(@locators['email_confirmation']['type'].to_sym, @locators['email_confirmation']['selector'])
      setElement(email_element, email_address)
    end


    def phone=(number)
      @locat.where(step: "fullphone").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => '9999999999')
        rescue => e

        end
      end

      @locat.where(step: "phone1").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => '999')
        rescue => e

        end
      end

      @locat.where(step: "phone2").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => '999')
        rescue => e

        end
      end

      @locat.where(step: "phone3").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => '9999')
        rescue => e

        end
      end
    end



    def first_name=(name)
      @locat.where(step: "firstname").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => 'Digital')
        rescue => e

        end
      end
    end



    def last_name=(name)
      @locat.where(step: "lastname").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => 'Automation')
        rescue => e

        end
      end
    end


    def address=(address)
      @locat.where(step: "address1").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => '123 QATest Street')
        rescue => e

        end
      end
      @locat.where(step: "address1").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => '123 QATest Street')
        rescue => e

        end
      end
    end

    def city=(city)
      @locat.where(step: "city").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => 'Anywhere')
        rescue => e

        end
      end
    end



    def state=(state)
      @locat.where(step: "state").each do |locator|
        begin
          @browser.find(:css, locator.css).select('CA')
        rescue => e

        end
      end
      
      @locat.where(step: "state").each do |locator|
        begin
          @browser.find(:css, locator.css).select('California')
        rescue => e

        end
      end
    end

    def zip=(zip)
      @locat.where(step: "zip").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => '90405')
        rescue => e

        end
      end
    end

    def credit_card_number=(creditCardNumber)
      @locat.where(step: "ccnumber").each do |locator|
        begin
          @browser.fill_in(locator.css, :with => '4111111111111111')
        rescue => e

        end
      end
    end


    def credit_card_month=(creditCardMonth)
      @locat.where(step: "ccmonth").each do |locator|
        begin
          @browser.find(:css, locator.css).select('07')
        rescue => e

        end
      end

      @locat.where(step: "ccmonth").each do |locator|
        begin
          @browser.find(:css, locator.css).select('July')
        rescue => e

        end
      end

      @locat.where(step: "paymentmethod").each do |locator|
        begin
          @browser.find(:css, locator.css).select('Visa')
        rescue => e

        end
      end
    end

    def credit_card_year=(creditCardYear)
      @locat.where(step: "ccyear").each do |locator|
        begin
          @browser.find(:css, locator.css).select('2019')
        rescue => e

        end
      end
    end

    def offercode()
      offercode = nil
      @locat.where(step: "coreid").each do |locator|
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

    def vitamin_offercode()
      offercode = nil
      @locat.where(step: "vitaminid").each do |locator|
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

    def shipping(type)
      shipping_val = nil

      @locat.where(step: "shipping_dropdown_#{type}").each do |locator|
        begin
          price_element = @browser.first(:css, locator.css, :visible => false)
          price_string = price_element.base.all_text().scan(@price_regex).first
          shipping_val = price_string
          Rails.logger.info shipping_val
        rescue => e

          begin
            price_element = @browser.first(:css, locator.css, :visible => false)
            price_string = price_element.text().scan(@price_regex).first
            shipping_val = price_string
            Rails.logger.info shipping_val
          rescue => e

          end
        end
      end

      return shipping_val
    end

    ##
    # Returns the campaign code for this page
    # @param [String] javascript_variable The Campaign variable in javascript that needs to be called
    # @return [object] javascript response (can be a string, can be an object)
    def grcid(javascript_variable: 'mmCampaign')
      @locat.where(step: "grcid_js_variable").each do |locator|
        grcid_code = js_return(locator.css)

        if(grcid_code)
          return grcid_code
        end
      end
      return 'N/A'
    end

    def agreetoterms(state = true)
      @locat.where(step: "agreecheck").each do |locator|
        begin
          @browser.find(:css, locator.css).click()
        rescue => e
          
        end
        begin
          @browser.first(:css, locator.css, :visible => false).set(true)
        rescue => e

        end
        begin
          @browser.first(:css, locator.css).set(true)
        rescue => e

        end
      end
    end
  end
end # end of t5 module
