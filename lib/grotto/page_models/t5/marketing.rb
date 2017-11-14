module T5
  class Marketing < BasePage
    def adapt()
      template = @campaign_configuration["DesktopHomePageTemplate"]

      Rails.logger.info "template: #{template}"
      case template
      when 'DHP1', 'MPH1'
        page = HomePage.new(@campaign_configuration)
      when 'DHP2', 'MPH2'
        page = LandingPage.new(@campaign_configuration)
      when 'DMH', 'MMH'
        Rails.logger.info "UNIMPLEMENETED TEMPLATE: #{@campaign_configuration.cart} - Using 'DHP1'"
        page = HomePage.new(@campaign_configuration)
      when 'LegacyMobileHome'
        page = LegacyMobileHome.new(@campaign_configuration)
      else
        page = HomePage.new(@campaign_configuration)
      end

      page.browser = browser
      return page
    end # of adapt method

    def go_to_orderpage()
      @orderbtns = Locator.where(:step => 'Ordernow')
      puts @orderbtns
    end
  end # of Marketing class

  class HomePage < Marketing
    def homepage_popovers
      #js_exec "$('.ui-dialog-titlebar-close').click()"
      js_exec("$('.tv0ffer-popup').hide()")
      #js_exec("$('.special-offers-popup').hide()")
      js_exec("$('.ui-widget-overlay').hide()")
    end

    def click_all_orderbtns(orderbtns)
      orderbtns.each do |btn|
        puts btn.css
        click_if_exists(:css, btn.css)
      end
    end

    def go_to_productpage()
      puts "Homepage product page"
      begin
        if(@browser.has_selector?(:xpath, './/ul/li[@class="products "]/a'))
          @browser.find(:xpath, './/ul/li[@class="products "]/a').click
        elsif(@browser.has_selector?(:xpath, './/ul/li[@data-menu="ShopAll"]/a'))
          @browser.find(:xpath, './/ul/li[@data-menu="ShopAll"]/a').click
        end
      rescue => e
            
      end
      page = T5::SAS.new(@campaign_configuration)
      page.browser = @browser
      return page.adapt
    end

    def go_to_orderpage()
      puts "Homepage orderpage"
      super()
      puts "done fetch locator"
      homepage_popovers
      puts @orderbtns
      click_all_orderbtns(@orderbtns)
      js_exec("$('.slide1 a.bigButton')[0].click()")
      if(@browser.first('.special-offers-popup') || @browser.first('.popover') || @browser.first('.tv0ffer-popup'))
        homepage_popovers
        sleep(2)
      end
      click_all_orderbtns(@orderbtns)

      page = T5::SAS.new(@campaign_configuration)
      page.browser = @browser
      return page.adapt
    end # of go_to_orderpage

    # def go_to_orderpage()
    #   super()
    #   sleep(5) if(desktop? && @campaign_configuration['Brand'] == 'MeaningfulBeauty')
    #   homepage_popovers
    #   click_all_orderbtns(@orderbtns)
    #   js_exec("$('.slide1 a.bigButton')[0].click()")
    #   if(@browser.first('.special-offers-popup') || @browser.first('.popover') || @browser.first('.tv0ffer-popup'))
    #     homepage_popovers
    #     sleep(2)
    #   end
    #   click_all_orderbtns(@orderbtns)

    #   if(desktop? && @campaign_configuration['Brand'] == 'MeaningfulBeauty')
    #     sleep(1)
    #     click_all_orderbtns(@orderbtns)
    #   end

    #   page = T5::SAS.new(@campaign_configuration)
    #   page.browser = @browser
    #   return page.adapt
    # end # of go_to_orderpage
  end # of HomePage class

  class Banner < Marketing

  end # of Banner class

  class LandingPage < Marketing

  end # of LandingPage class

  class LegacyMobileHome < HomePage

  end # of LandingPage class
end
