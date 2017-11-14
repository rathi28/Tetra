module T5
  # The SAS class doubles as both a super-class
  # for select-a-system pages but also as a interface
  # for its subclasses
  class SAS < BasePage
    @steps_loc  = []
    @offer      = nil
    # Looks at page to figure out what the module type is, and returns that module
    def adapt()
      # get template for SAS from configuration
      template = @campaign_configuration["DesktopSASTemplate"]
      
      # print the template used
      Rails.logger.info "template: #{template}"

      # check the campaign configuration and store the page 
      case template
      when 'DP1' # Desktop Product Buyflow
        page = CartCheckoutFlow.new(@campaign_configuration)
      when 'DIL1' # Desktop Inline1
        page = Inline.new(@campaign_configuration)
      when 'DIL2' # Desktop Inline1
        page = Inline.new(@campaign_configuration)
      when 'DAL1' # Desktop Airline1
        page = Airline.new(@campaign_configuration)
      when 'DAL2' # Desktop Airline2
        page = Airline.new(@campaign_configuration)
      when 'DMS', 'MMS' # Desktop ????
        Rails.logger.info "UNIMPLEMENETED TEMPLATE: '#{@campaign_configuration.cart}' - Using 'DIL1'"
        page = Inline.new(@campaign_configuration)
      when 'responsive'
        page = Reponsive.new(@campaign_configuration)
      # Mobile Templates (One fits all for new style sites)
      when 'MobileA', 'MIL2', 'MIL1', 'MAL1', 'MAL2' 
        page = MobileSASA.new(@campaign_configuration)
      when 'MobileB'
        page = MobileSASB.new(@campaign_configuration)

      when 'MobileC'
        page = MobileSASC.new(@campaign_configuration)
        # Legacy Template for sites like Supersmile & Reclaim Botanical
      when 'LegacyTemplate'
        page = LegacySAS.new(@campaign_configuration)
        # Realm2 Template for Responsive sites (Mostly needed for mobile campaigns that use T4 responsive on Realm2)
      when 'Realm2Responsive'
        page = Realm2Responsive.new(@campaign_configuration)
      else
        page = Inline.new(@campaign_configuration)
      end
      page.browser = @browser
      return page
    end

    def get_locators
      begin
        selection_locators = []
        locators = js_return "variantValuesArrayJsonString"
        locators.each do |item,value|
          value[0].each do |key, locator|
            selection_locators.push "." + locator
          end
        end

      rescue => e
        return nil
      end
      result = ::GRDatabase.validate_locators(selection_locators)
    end

    def get_options()
      options = []
      begin
        options_loc = js_return "currentSelectionArrayJsonString"
      rescue => e
        return nil
      end
      options_loc[0].each do |key, locate|
        options.push GRDatabase.get_locator_step '.' + locate
      end
      return options
    end

    # skips SAS selection and goes to the cart module
    def skip_to_cart
      raise UnimplementedMethod.new('skip_to_cart is not implemented for this SAS module')
    end # interface like method

    def find_locator()
      @steps_loc.each do |locator|

      end
    end

    def check_pricing(price)
      # get all elements for price
      price_fields = @browser.all(:css, '.kit-price')
      wrong_prices = []
      price_fields.each do |field|
        if field.text().include?(price)
          # Do nothing
        else
          wrong_prices.push(field.text())
        end
      end
      if wrong_prices.empty?
        return nil
      else
        return wrong_prices
      end
    end


    def click_all_locators(locator_list)
      js_exec("$('#inqChatStage').hide()")
      locator_list.each do |locator|
        sleep(2) if @browser.first(locator['css'])
        click_if_exists :css, locator['css']
        Rails.logger.info locator['css']
      end
    end

    def select_options(offer)
      @offer = offer
      begin
        @steps_loc = get_locators()
      rescue => e
        e.display
      end
      begin
        pages = get_pattern
        Rails.logger.info pages
        pages.each do |page|
          page.each do |step|
            begin
              case step
              when "Product", "Brandpseudo"
                select_product
              when "Kit"
                select_kit
              when "Gift"
                select_gift
              when "Supply"
                select_supply
              when "Fragrance"
                select_fragrance
              when "Shade"
                select_shade
              when "Formula"
                select_formula
              when "Pack"
                select_pack
              when "Duo"
                select_duo
              end 
            rescue => e
              e.display
            end
          end #of step execution
        end #of sas module selection 
        click_if_exists(:css, '#checkout.marketing-button-next')
        Locator.where(step: "NextCheckout").each do |locator|
           Rails.logger.debug "NextCheckout========================="
           Rails.logger.debug @browser.inspect
            begin
              @browser.first(:css, locator.css).click()
            rescue => e
            end
          end 
      rescue => e
        e.display
        # TODO handle other situations
      end
    end # interface lke method

    # = Interface Methods for SAS Pages


    def select_gift
      raise UnimplementedMethod.new('select_product is not implemented for this SAS module')
    end # interface like method

    def select_product
      raise UnimplementedMethod.new('select_product is not implemented for this SAS module')
    end # interface like method

    def select_formula
      raise UnimplementedMethod.new('select_formula is not implemented for this SAS module')
    end # interface like method

    def select_supply
      raise UnimplementedMethod.new('select_supply is not implemented for this SAS module')
    end # interface like method

    def select_pack
      raise UnimplementedMethod.new('select_pack is not implemented for this SAS module')
    end # interface like method

    def select_duo
      raise UnimplementedMethod.new('select_pack is not implemented for this SAS module')
    end # interface like method

  end # end of SAS Class

  # Template for Product Buyflow
  class CartCheckoutFlow < SAS
    def select_options(offer)
      puts offer.length
      puts offer
      offercount = 0
      offer.each do |entry|
        puts entry.campaign.Brand
        puts entry['Offer']
        
        locators = GRDatabase.get_all_locators("CartFlow", entry.campaign.Brand, entry['Offer'])
        puts locators
        begin
          click_all_locators(locators)
        rescue => e

        end
        offercount += 1
        change_supply_size(entry)
        add_to_cart()
        shop_more() if(offercount<(offer.length))
      end
      move_to_checkout()
      
      # page = T5::SAS.new(@campaign_configuration)
      # page.browser = @browser
      # return page.adapt

      page = T5::Cart.new(@campaign_configuration)
      page.browser = @browser
      return page.adapt
    end

    def change_supply_size(offer)
      begin
        puts "change_supply_size"
        puts offer['SupplySize']
        if(offer['SupplySize'] == '30')
          @browser.find(:xpath, './/a[@title="1-Month Supply"]').click
        elsif(offer['SupplySize'] == '90')
          @browser.find(:xpath, './/a[@title="3-Month Supply"]').click
        end
      rescue => e

      end
    end

    def shop_more()
      begin
        if(@browser.has_selector?(:xpath, './/ul/li[@class="products "]/a'))
          @browser.find(:xpath, './/ul/li[@class="products "]/a').click
        elsif(@browser.has_selector?(:xpath, './/ul/li[@data-menu="ShopAll"]/a'))
          @browser.find(:xpath, './/ul/li[@data-menu="ShopAll"]/a').click
        end
      rescue => e
            
      end
    end

    # def change_supply_size(offer)
      
    def add_to_cart()
      @addtocart_btn = Locator.where(:step => 'add_to_cart')
      begin
        click_all_locators(@addtocart_btn)
      rescue => e

      end
    end

    def move_to_checkout()
      @checkout_btn = Locator.where(:step => 'Checkout')
      begin
        if(@checkout_btn)
          click_all_locators(@checkout_btn)
        else
          @viewcart_btn = Locator.where(:step => 'view_cart')
          click_all_locators(@viewcart_btn)
          click_all_locators(@checkout_btn)
        end
      rescue => e
        
      end

      # page = T5::Cart.new(@campaign_configuration)
      # page.browser = @browser
      # return page.adapt
    end
  end

  # Template for pages where all steps are on one page
  class Inline < SAS

    def get_steps
      @browser.all '.slider .list-container'
    end

    # 
    def skip_to_cart()
      @continue_btns = Locator.where(:step => 'ContinueButton')
      @continue_btns.each do |btn|
        click_if_exists(:css, btn.css)
      end

      page = T5::Cart.new(@campaign_configuration)
      page.browser = @browser
      return page.adapt
    end

    ##
    # Selects the options for the offer based on the page pattern given by configuration
    # @param [OfferData] offer an Offerdata object from the database
    # @return [T5:Cart]
    def select_options(offer)
      puts "basepage select options"
      @offer = offer.first
      begin
        @steps_loc = get_locators()
        puts "steps_loc loc"
        puts @steps_loc
        puts "loc done"
      rescue => e
        e.display
      end
      begin
        pages = get_pattern
        puts "pages"
        puts pages
        puts "pages done"
        Rails.logger.info pages
        pages.each do |page|
          puts "page"
          puts page
          puts "page"
          page.each do |step|
            puts "step"
            puts step
            puts "step"
            begin
              case step
              when "Product", "Brandpseudo"
                select_product
              when "Kit"
                select_kit
              when "Gift"
                select_gift
              when "Supply"
                select_supply
              when "Fragrance"
                select_fragrance
              when "Shade"
                select_shade
              when "Formula"
                select_formula
              when "Pack"
                select_pack
              when "Duo"
                select_duo
              end 
            rescue => e
              e.display
            end
          end #of step execution
        end #of sas module selection 
        # click_if_exists(:css, '#checkout.marketing-button-next')
      rescue => e
        e.display
        # TODO handle other situations
      end

      page = T5::Cart.new(@campaign_configuration)
      page.browser = @browser
      return page.adapt
    end

    ##
    # iterates through all the locators for this brand, the given step and the given column from offergrid
    # @param [String] step   The step for locators needed
    # @param [String] column The column from the offer row needed
    # @return [nil]
    def general_locator_clicker(step, column)
      Rails.logger.info "Clicking Locator for #{step}"
      locators = GRDatabase.get_all_locators(step, @offer.campaign.Brand, @offer[column])
      begin
        click_all_locators(locators)
      rescue => e

      end
    end

    def select_kit
      general_locator_clicker("Kit", 'Offer')
      click_if_exists(:css, '#kit ~ .market a.buttons-next')
    end

    def select_gift
      sleep(1)
      general_locator_clicker("Gift", 'Bonus')
      click_if_exists(:css, '#gift ~ .market a.buttons-next')
    end 

    def select_supply
      sleep(1)
      general_locator_clicker("Supply", 'SupplySize')
      click_if_exists(:css, '#supply ~ .market a.buttons-next')
    end 

    def select_fragrence
      sleep(1)
      general_locator_clicker("Fragrance", 'ExtraStep')
      click_if_exists(:css, '.kit .marketing-button-next')
    end 

    def select_shade
      sleep(1)
      general_locator_clicker("Shade", 'ExtraStep')
      click_if_exists(:css, '.shade .marketing-button-next')
    end 

    def select_formula
      sleep(1)
      general_locator_clicker("Formula", 'ExtraStep')
      click_if_exists(:css, '.formula .marketing-button-next')
    end 

    def select_pack
      sleep(1)
      general_locator_clicker("ValuePack", 'ExtraStep')
      click_if_exists(:css, '.valuepack .marketing-button-next')
    end

    def select_duo
      sleep(1)
      general_locator_clicker("Duo", 'ExtraStep')
      click_if_exists(:css, '.supply .marketing-button-next')
    end

    def select_product
      begin
        # if(@offer['Offer'].include?('PA+') || @offer['Offer'].include?('Proactiv+'))
        #   locators = GRDatabase.get_all_locators("Product", 'ProactivPlus', 'ProactivPlus')
        # else
        #   locators = GRDatabase.get_all_locators("Product", 'ProactivPlus', 'Proactiv')
        # end
        click_all_locators locators
      rescue => e
        e.display
      end
      begin
        click_if_exists(:css, '.brandpseudo .marketing-button-next')
      rescue => e
        e.display
      end	
    end    
  end # end of Inline Class

  # Template where each step is on a different page
  class Airline < Inline
    # TODO Create Airline Object
    def skip_to_cart()
      # get all the continue buttons from the locator database table
      @continue_btns = Locator.where(:step => 'ContinueButton')


      @continue_btns.each do |btn|
        click_if_exists(:css, btn.css)
      end

      # click through the next buttons for T5 style websites
      (0..1).each do |num|
        click_if_exists(:css, '.kit .marketing-button-next')
        click_if_exists(:css, '.gift .marketing-button-next')
        click_if_exists(:css, '.product .marketing-button-next')
        click_if_exists(:css, '.supply .marketing-button-next')
      end
      page = T5::Cart.new(@campaign_configuration)
      page.browser = @browser
      return page.adapt
    end # of skip_to_cart

  end # end of Airline Class

  # This general Mobile template handles all situations for mobile for most sites.
  # MobileA, MobileB, and MobileC are available if needed, but in most cases won't be, and up to this point we haven't had a specific workaround that needs those classes.
  class MobileSAS < Inline
    def skip_to_cart()
      # get all the continue buttons from the locator database table
      @continue_btns = Locator.where(:step => 'ContinueButton')

      # click all continue your order/next step buttons
      @continue_btns.each do |btn|
        click_if_exists(:css, btn.css)
      end

      # instantiate the cart superclass and call its adapt method to create the subclass needed based on the campaign configuration
      page = T5::Cart.new(@campaign_configuration)
      # Pass along the browser
      page.browser = @browser
      # request the subclass for configuration
      return page.adapt
    end # of skip_to_cart

    def select_product
      # if(@offer['Offer'].include?('PA+') || @offer['Offer'].include?('Proactiv+'))
      #     locators = GRDatabase.get_all_locators("Product1", 'ProactivPlus', 'ProactivPlus')
      # else
      #   locators = GRDatabase.get_all_locators("Product1", 'ProactivPlus', 'Proactiv')
      # end

      click_all_locators locators

      # if(@offer['Offer'].include?('PA+') || @offer['Offer'].include?('Proactiv+'))
      #     locators = GRDatabase.get_all_locators("Product2", 'ProactivPlus', 'ProactivPlus')
      # else
      #   locators = GRDatabase.get_all_locators("Product2", 'ProactivPlus', 'Proactiv')
      # end
      click_all_locators locators

      super()
      sleep(1)
      click_if_exists(:css, '.orderVarButton-null')
    end
    
    def select_kit
      sleep(1)
      general_locator_clicker("Kit1", 'Offer')
      sleep(1)
      general_locator_clicker("Kit2", 'Offer')
      super()
      sleep(1)
      click_if_exists(:css, '.orderVarButton-null')
    end

    def select_gift
      sleep(1)
      general_locator_clicker("Gift1", 'Bonus')
      sleep(1)
      general_locator_clicker("Gift2", 'Bonus')
      super()
      sleep(1)
    end

    def select_shade
      sleep(1)
      general_locator_clicker("Shade1", 'ExtraStep')
      sleep(1)
      general_locator_clicker("Shade2", 'ExtraStep')
	  super()
    end

    #Adding to select formula's in Mobile (Wen)
    def select_formula
      sleep(1)
      general_locator_clicker("Formula1", 'ExtraStep')
      sleep(1)
      general_locator_clicker("Formula2", 'ExtraStep')
	  super()
    end
  end

  # Mobile SAS A is an extra class the Proactiv
  class MobileSASA < MobileSAS

  end #of MobileSASA Class

  # Mobile SAS A is an extra class that sites like Proactiv
  class MobileSASB < MobileSAS

  end #of MobileSASB Class

  # This mobile template is needed for Wen and Sheercover non-responsive mobile only version
  class MobileSASC < MobileSAS

    # Special select_formula that uses a workaround for the slider
    def select_formula
      case @offer['ExtraStep']
        # Standard Formulas - always available
      when 'SAM'
        js_exec('mySwipe.slide(0)')
      when 'LAV'
        js_exec('mySwipe.slide(1)')
      when 'POM'
        js_exec('mySwipe.slide(2)')
        # Seasonal Specials are always the last item in slider
      when 'Summer'
        js_exec('mySwipe.slide(3)')
      when 'Spring'
        js_exec('mySwipe.slide(3)')
      when 'Winter'
        js_exec('mySwipe.slide(3)')
      else

      end
      # click the continue buttons
      click_if_exists(:css, '#sas-cto2.orderakitbtn')
      click_if_exists(:css, '#sas-cto1.orderakitbtn')
    end # interface like method

    # special selector for Sheercover sites shade step
    def select_shade
      sleep(1)
      general_locator_clicker("Shade1", 'ExtraStep')
      sleep(1)
      general_locator_clicker("Shade2", 'ExtraStep')
    end     
  end #of MobileSASC Class

  # this is a Legacy class for sites like Supersmile and Reclaim Botanical
  class LegacySAS < MobileSAS

  end #of LegacyTemplate

  # this class
  class Realm2Responsive < Inline
    # Add the carts offercode get method to compare and handle issues with selection
    def offercode()
      get_value do
        return @browser.first(:css, '.offerCodeID').text().strip
      end
    end

    # wrap supermethod in some error handling for this responive design
    def select_options(offer)
      # potential steps with carousel
      steps = [
        'kit',
        'gift',
        'supply',
        'valuepack'
      ]

      # set attempts counter to 0 to instantiate the variable
      attempts = 0
      begin
        # call the superclass method within handler
        page = super(offer)
        if(offer['OfferCode'] != offercode())
          # Raise an error if the offer code is wrongly picked
          raise 'mismatched offer'
        end
        return page
      rescue
        attempts += 1
        # for each step, kick the owl-slider to move it one slide
        steps.each do |step| 
          begin
            # call slide method for a step
            slide(step)
          rescue => e
            # print out any issues for debugging
            Rails.logger.info e.message
            Rails.logger.info e.backtrace if e.backtrace
          end
        end
        retry if attempts < 3
        return page
      end
    end
    ##
    # slide over the slider for a particular step one slide
    # NOTE - This only works for the Realm2 Responsive sites
    # @param [String] step Which step's slider needs to be pushed over
    def slide(step)
      js_exec("$('.#{step}.owl-carousel').data('owlCarousel').next();")
    end
  end # end of Realm2Responsive
end # end of T5 Module
