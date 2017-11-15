require 'selenium-webdriver'
require 'capybara'
require 'capybara/poltergeist'
require 'open-uri'
require 'json'
=begin

This class is used construct Capybara sessions, and contact Browserstack to request a new device.

=end
class BrowserFactory
  
  
  # Generates a capybara browser for the page model
  def self.create_browser(driver = "chrome")
    puts "creating browser"
    puts driver
    case (driver.downcase)

    when 'poltergeist', 'phantomjs'
        # PhantomJS web browser - headless testing
        browser = self.poltergeist_driver()

      when 'selenium-webdriver', 'local', 'firefox', 'local-firefox'
        # regular local capybara sessions for Firefox
        browser = self.firefox

      when 'local-chrome', 'chrome'
        puts "creating chrome"
        # regular local capybara sessions for Chrome
        browser = self.chrome
puts "created chrome"
      when 'local-ie', 'ie', 'ie11'
        # regular local capybara sessions for IE11
        browser = self.ie

      when 'local-iphone'
        # firefox emulation and spoofing for writing tests
        browser = self.firefox_iphone

      when 'local-ipad' # NEEDS TO BE IMPLEMENTED
         # firefox emulation and spoofing for writing tests
         browser = self.firefox_ipad

      # when 'local-android'# NEEDS TO BE IMPLEMENTED
      #   # firefox emulation and spoofing for writing tests
      #   browser = self.selenium_local_driver(:android_phone)
      #   browser.driver.browser.manage.window.resize_to(360,640)
      when 'grid-chrome'
        browser = self.grid_driver('grid-chrome')

      when 'grid-ie'
        browser = self.grid_driver('grid-ie')

      when 'grid-firefox'
        browser = self.grid_driver('grid-firefox')

      when 'grid-iphone'
        browser = self.grid_driver('grid-iphone')
        
      when 'grid-ipad'
        browser = self.grid_driver('grid-ipad')
        
      when 'remote-chrome'
        browser = self.remote_driver(:chrome)

      when 'android'
        # Depreciated but still functional-ish
        # Browserstack device
        browser = self.remote_driver(:android)

      when 'galaxy-s5'
        # on hold but still functional-ish
        # Browserstack device
        browser = self.remote_driver(:samsung_galaxy_s)

      when 'galaxy-note'
        # on hold but still functional-ish
        # Browserstack device
        browser = self.remote_driver(:samsung_galaxy_note)

      when 'iphone'
        # Browserstack device
        Rails.logger.info 'Browserstack iPhone Driver'
        browser = self.remote_driver(:iphone)

      when 'ipad'
        # Browserstack device
        browser = self.remote_driver(:ipad)

      when 'safari'
        # on hold but still functional-ish
        browser = self.remote_driver(:safari)
      else
        puts "creating chrome"
        # if no option found, default to Chrome
        browser = self.chrome
      end
      return browser
    end

    # Prevents early timeouts
    def self.set_default_timeout
      client = Selenium::WebDriver::Remote::Http::Default.new
      client.timeout = 180
      return client
    end
    private_class_method :set_default_timeout

    # Generates a new Capybara Session for the latest IE
    def self.ie
      client = set_default_timeout()
      caps = Selenium::WebDriver::Remote::Capabilities.internet_explorer('ie.ensureCleanSession' => true, 'ie.browserCommandLineSwitches' => 'private')
      Capybara.register_driver :ie do |app|
        Capybara::Selenium::Driver.new(
          app,
          :browser => :ie,
          :http_client => client,
          :desired_capabilities => caps
          )
      end
      session = Capybara::Session.new(:ie)
      session.driver.browser.manage.window.maximize
      session.driver.browser.manage.delete_all_cookies
      return session
    end

    def self.grid_browser_mob_chrome(proxy)
      client = set_default_timeout()
      url = "http://#{self.grid_hub_ip}:4444/wd/hub"
      Rails.logger.info 'grid firefox browser'
      proxy = Selenium::WebDriver::Proxy.new(:http => @proxy, :ssl => @proxy)
      caps = Selenium::WebDriver::Remote::Capabilities.chrome(:proxy => proxy_sel)
      Capybara.register_driver :grid_firefox_proxy do |app|
        Capybara::Selenium::Driver.new(
          app,
          :url => url,
          :browser => :remote,
          :http_client => client,
          :desired_capabilities => caps
        )
      end
      Capybara.default_driver = :grid_firefox_proxy
      session = Capybara::Session.new(:grid_firefox_proxy)
      session.driver.browser.manage.window.maximize
      return session
    end

    def self.grid_browser_mob_firefox(proxy)
      puts "In browser factory"
      client = set_default_timeout()
      url = "http://#{self.grid_hub_ip}:4444/wd/hub"
      puts "url"
      Rails.logger.info 'grid firefox browser'
      profile     = Selenium::WebDriver::Firefox::Profile.new
      proxy_sel   = proxy.selenium_proxy(:http, :ssl)
      puts "creating proxy"
      # proxy_sel = Selenium::WebDriver::Proxy.new(:type => :manual, :http => @proxy)
      profile['browser.cache.disk.enable']    = false
      profile['browser.cache.memory.enable']  = false
      profile['browser.cache.offline.enable'] = false
      profile['network.http.use-cache']       = false
      # profile['assume_untrusted_certificate_issuer'] = false
      caps = Selenium::WebDriver::Remote::Capabilities.firefox(:firefox_profile => profile, :proxy => proxy_sel)
      Capybara.register_driver :grid_firefox_proxy do |app|
        Capybara::Selenium::Driver.new(
          app,
          :url => url,
          :browser => :remote,
          :http_client => client,
          :desired_capabilities => caps
        )
      end
      Capybara.default_driver = :grid_firefox_proxy
      session = Capybara::Session.new(:grid_firefox_proxy)
      session.driver.browser.manage.window.maximize
      return session

      # client = set_default_timeout()
      # Capybara.register_driver :iphone do |app|
      #   profile = Selenium::WebDriver::Firefox::Profile.new
      #   profile['general.useragent.override'] = 'iphone'
      #   Capybara::Selenium::Driver.new(app, :profile => profile, :http_client => client)
      # end
      # Capybara.default_driver = :iphone
      # session = Capybara::Session.new(:iphone)
    end

    def self.grid_browser_mob_firefox_iphone(proxy)

      client = set_default_timeout()
      url = "http://#{self.grid_hub_ip}:4444/wd/hub"
      Rails.logger.info 'iphone emulating browser'
      profile     = Selenium::WebDriver::Firefox::Profile.new
      proxy_sel   = proxy.selenium_proxy(:http, :ssl)
      profile['browser.cache.disk.enable']    = false
      profile['browser.cache.memory.enable']  = false
      profile['browser.cache.offline.enable'] = false
      profile['network.http.use-cache']       = false
      profile['general.useragent.override']   = 'iphone'
      caps = Selenium::WebDriver::Remote::Capabilities.firefox(:firefox_profile => profile, :proxy => proxy_sel)
      Capybara.register_driver :grid_iphone do |app|
        Capybara::Selenium::Driver.new(
          app,
          :url => url,
          :browser => :remote,
          :http_client => client,
          :desired_capabilities => caps
        )
      end
      Capybara.default_driver = :grid_iphone
      session = Capybara::Session.new(:grid_iphone)
      session.driver.browser.manage.window.resize_to(360,568)
      return session
    end

    def self.grid_browser_mob_firefox_ipad(proxy)
      client = set_default_timeout()
      url = "http://#{self.grid_hub_ip}:4444/wd/hub"
      Rails.logger.info 'ipad emulating browser'
      profile = Selenium::WebDriver::Firefox::Profile.new
      proxy_sel = proxy.selenium_proxy(:http, :ssl)
      profile['browser.cache.disk.enable']    = false
      profile['browser.cache.memory.enable']  = false
      profile['browser.cache.offline.enable'] = false
      profile['network.http.use-cache']       = false
      profile['general.useragent.override']   = 'Mozilla/5.0 (iPad; CPU OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53'
      caps = Selenium::WebDriver::Remote::Capabilities.firefox(:firefox_profile => profile, :proxy => proxy_sel)
      Capybara.register_driver :grid_ipad do |app|
        Capybara::Selenium::Driver.new(
          app,
          :url => url,
          :browser => :remote,
          :http_client => client,
          :desired_capabilities => caps
        )
      end
      Capybara.default_driver = :grid_ipad
      session = Capybara::Session.new(:grid_ipad)
      session.driver.browser.manage.window.resize_to(1024,768)
      return session
    end

    def self.grid_hub_ip
      #@grid_hub = "192.168.1.254"
      @grid_hub = Grid_Processes.where('role = ?', "hub").first.ip
      return @grid_hub
    end
    
    def self.grid_driver(selected)
      client = set_default_timeout()
      url = "http://#{self.grid_hub_ip}:4444/wd/hub"
      case selected
      when "grid-chrome"
        caps = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {"args" => [ "—test-type -allow-running-insecure-content" ]})
        Capybara.register_driver :grid_chrome do |app|
          Capybara::Selenium::Driver.new(
            app,
            :url => url,
            :browser => :remote,
            :http_client => client,
            :desired_capabilities => caps)
        end
        Capybara.server_port = 3010
        Capybara.current_driver = :grid_chrome
        Capybara.javascript_driver = :grid_chrome
        session = Capybara::Session.new(:grid_chrome)
        session.driver.browser.manage.window.maximize
        return session
      when "grid-firefox"
        caps = Selenium::WebDriver::Remote::Capabilities.firefox()
        Capybara.register_driver :grid_firefox do |app|
          Capybara::Selenium::Driver.new(
            app,
            :url => url,
            :browser => :remote,
            :http_client => client,
            :desired_capabilities => caps)
        end
        Capybara.server_port = 3010
        Capybara.current_driver = :grid_firefox
        Capybara.javascript_driver = :grid_firefox
        session = Capybara::Session.new(:grid_firefox)
        session.driver.browser.manage.window.maximize
        return session
      when "grid-ie"
        caps = Selenium::WebDriver::Remote::Capabilities.internet_explorer()
        Capybara.register_driver :grid_ie do |app|
          Capybara::Selenium::Driver.new(
            app,
            :url => url,
            :browser => :remote,
            :http_client => client,
            :desired_capabilities => caps)
        end
        Capybara.server_port = 3010
        Capybara.current_driver = :grid_ie
        Capybara.javascript_driver = :grid_ie
        session = Capybara::Session.new(:grid_ie)
        session.driver.browser.manage.window.maximize
        return session
      when "grid-iphone"
        Rails.logger.info 'iphone emulating browser - grid'
        profile = Selenium::WebDriver::Firefox::Profile.new
        profile['general.useragent.override'] = 'iphone'
        caps = Selenium::WebDriver::Remote::Capabilities.firefox(:firefox_profile => profile)
        Capybara.register_driver :grid_iphone do |app|
          Capybara::Selenium::Driver.new(
            app,
            :url => url,
            :browser => :remote,
            :http_client => client,
            :desired_capabilities => caps
          )
          end
        Capybara.default_driver = :grid_iphone
        session = Capybara::Session.new(:grid_iphone)
        session.driver.browser.manage.window.resize_to(360,568)
        return session
      when "grid-ipad"
        Rails.logger.info 'ipad emulating browser - grid'

        profile = Selenium::WebDriver::Firefox::Profile.new
        profile['general.useragent.override'] = 'Mozilla/5.0 (iPad; CPU OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53'
        caps = Selenium::WebDriver::Remote::Capabilities.firefox(:firefox_profile => profile)
        Capybara.register_driver :grid_ipad do |app|
          Capybara::Selenium::Driver.new(
            app,
            :url => url,
            :browser => :remote,
            :http_client => client,
            :desired_capabilities => caps
          )
          end
        Capybara.default_driver = :grid_ipad
        session = Capybara::Session.new(:grid_ipad)
        session.driver.browser.manage.window.resize_to(1024,768)
        return session
      else
        caps = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {"args" => [ "—test-type -allow-running-insecure-content" ]})
        Capybara.register_driver :grid_chrome do |app|
          Capybara::Selenium::Driver.new(
            app,
            :url => url,
            :browser => :remote,
            :http_client => client,
            :desired_capabilities => caps)
        end
        Capybara.server_port = 3010
        Capybara.current_driver = :grid_chrome
        Capybara.javascript_driver = :grid_chrome
        session = Capybara::Session.new(:grid_chrome)
        session.driver.browser.manage.window.maximize
        return session
      end
    end

    # Generates a new Capybara Session for the latest Chrome
    def self.chrome
      client = set_default_timeout()
      Capybara.register_driver :chrome do |app|
        Capybara::Selenium::Driver.new(
          app,
          :browser => :chrome,
          :http_client => client,
          :switches => %w[—test-type -allow-running-insecure-content])
      end
      Capybara.javascript_driver = :chrome
      session = Capybara::Session.new(:chrome)
      session.driver.browser.manage.window.maximize
      return session
    end

    # Generates a new Capybara Session for the latest Firefox
    def self.firefox
      client = set_default_timeout()
      Capybara.default_driver = :selenium
      session = Capybara::Session.new(:selenium)
      session.driver.browser.manage.window.maximize
      return session
    end

    # Generates a new Capybara Session which emulates an iphone user using firefox profiles and user agent + viewport of iphone
    def self.firefox_iphone
      Rails.logger.info 'iphone emulating browser'
      client = set_default_timeout()
      Capybara.register_driver :iphone do |app|
        profile = Selenium::WebDriver::Firefox::Profile.new
        profile['general.useragent.override'] = 'iphone'
        Capybara::Selenium::Driver.new(app, :profile => profile, :http_client => client)
      end
      Capybara.default_driver = :iphone
      session = Capybara::Session.new(:iphone)
      session.driver.browser.manage.window.resize_to(360,568)
      return session
    end
    

    # Generates a new Capybara Session which emulates an iphone user using firefox profiles and user agent + viewport of iphone
    def self.firefox_ipad
      Rails.logger.info 'ipad emulating browser'
      client = set_default_timeout()
      Capybara.register_driver :ipad do |app|
        profile = Selenium::WebDriver::Firefox::Profile.new
        profile['general.useragent.override'] = 'Mozilla/5.0 (iPad; CPU OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53'
        Capybara::Selenium::Driver.new(app, :profile => profile, :http_client => client)
      end
      Capybara.default_driver = :ipad
      session = Capybara::Session.new(:ipad)
      session.driver.browser.manage.window.resize_to(1024,768)
      return session
    end

  # For when the test uses Selenium driver (default and development)
  # LEGACY - Deprecated and left until we clear out its use - perfered method is directly calling the class methods for the browser you want, rather than breaking into a submenu switch statement again
  def self.selenium_local_driver(browser = :firefox)
    #Rails.logger.info 'using selenium locally'
    case browser
    when :ie11
      return ie()
    when :chrome
      return chrome()
    when :firefox
      return firefox()
    when :iphone
      return firefox_iphone()
    end
  end

  # For when the test uses PhantomJS/Poltergeist
  def self.poltergeist_driver
    Rails.logger.info 'using poltergeist'
    Capybara.register_driver :poltergeist do |app|
      text = '' # For preventing Phantom JS log from clogging the normal log with extra outRails.logger.info.
      Capybara::Poltergeist::Driver.new(app, {:timeout => 120, :js_errors => false, :phantomjs_options => ['--ignore-ssl-errors=yes']}) # '--load-images=no',
    end
    Capybara.default_driver = :poltergeist
    session = Capybara::Session.new(:poltergeist)
    session.driver.headers = {'User-Agent' => 'Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2049.0 Safari/537.36'}
    return session
  end

  # TODO - Cmoseley - Remove this maybe?
  # For when the test uses remote browsers
  # def self.remote_driver(browsertype = :chrome)
  #   # TODO Rewrite this for desktop browsers
  #   return Capybara::Session.new(:selenium)
  # end

  # For when the test uses remote devices
  def self.remote_driver(device)
    client = Selenium::WebDriver::Remote::Http::Default.new
    client.timeout = 120
    Rails.logger.info 'using browserstack'
    url = "http://christophermosel2:DfURxDmhxpnQqZ2hyS6z@hub.browserstack.com/wd/hub"

    caps = Selenium::WebDriver::Remote::Capabilities.new

    caps['javascriptEnabled']   = 'true'
    caps['nativeEvents']        = 'true'
    caps['cssSelectorsEnabled'] = 'true'
    caps['acceptSslCert']       = 'true'
    caps['autoAcceptAlerts']    = 'true'

    # this should be turned off for production testing
    caps['browserstack.debug']  = 'true' # This flag allows you to see screenshots on browserstack
    all_device_caps = GRDatabase.get_browserstack_capabilities()
    device_caps     = all_device_caps[device.to_s] # getting configuration settings for this device

    # parsing device info into browserstack capability settings
    caps[:browserName]      = device_caps['browserName']      if(!device_caps['browserName'].nil?)
    caps[:platform]         = device_caps['platform']         if(!device_caps['platform'].nil?)
    caps['device']          = device_caps['device']           if(!device_caps['device'].nil?)
    caps['emulator']        = device_caps['emulator']         if(!device_caps['emulator'].nil?)
    caps['browser']         = device_caps['browser']          if(!device_caps['browser'].nil?)
    caps['browser_version'] = device_caps['browser_version']  if(!device_caps['browser_version'].nil?)
    caps['os']              = device_caps['os']               if(!device_caps['os'].nil?)
    caps['os_version']      = device_caps['os_version']       if(!device_caps['os_version'].nil?)
    caps['resolution']      = device_caps['resolution']       if(!device_caps['resolution'].nil?)

    Capybara.register_driver :browser_stack do |app|
      Capybara::Selenium::Driver.new(
        app,
        :browser => :remote, :url => url,
        :desired_capabilities => caps,
        :http_client => client
        )
    end

    Capybara.server_port        = 3010
    Capybara.default_wait_time  = 90
    Capybara.current_driver     = :browser_stack
    Capybara.javascript_driver  = :browser_stack

    # Create api accessor instance
    browserstack_api_accessor = BrowserstackAPI.new()
    browser_creation_attempts = 0 # set browser creation attempts to 0


    # This entire block could be replaced by an error handling wrap around method. 

    begin
      # Increment attempts counter for every attempt
      browser_creation_attempts += 1

      begin
        # Request number of browserstack sessions available to create
        slots = browserstack_api_accessor.get_available_slots
        # Raise error if connection has no available slots, which is caught by
        raise 'No Slots Available' if(slots == 0)
      rescue => e
        Rails.logger.info "Error - #{e.message}"
        Rails.logger.info "Waiting for BrowserStack slot"
        sleep(30)
      end

      # Call for capybara to create a session
      generated_capybara_session = Capybara::Session.new(:browser_stack)

      # visit a url to check that session was successfully generated
      generated_capybara_session.visit "http://www.google.com/"
      
      # return the successfully generated session
      return generated_capybara_session

    rescue Selenium::WebDriver::Error::UnknownError, Net::HTTPBadResponse => e
      # This block captures connection problems and retries connection in case it is a temporary issue
      
      # prints error message and then continues to find out end message content
      print "BrowserStack Failed to Connect"
      
      # Continue to try to connect up to 4 times
      unless browser_creation_attempts >= 4
        # Concludes message with note about reattempting connection
        Rails.logger.info " #{e.message} - retrying"
        # Retry connection
        sleep(15)
        retry
      end # for unless

      # Concludes message
      Rails.logger.info ""
      Rails.logger.info e.message
      raise "Failed to get browser from Browserstack - #{e.message}"

    rescue => e
      # This block captures connection problems and retries connection in case it is a temporary issue
      
      # prints error message and then continues to find out end message content
      if(e.message == "There was an error. Please try again.")
        print "BrowserStack Failed to Connect"
      end

      # Continue to try to connect up to 4 times
      unless browser_creation_attempts >= 4

        # Concludes message with note about reattempting connection
        Rails.logger.info " #{e.message} - retrying"
        
        # Retry connection
        sleep(15)
        retry

      end # for unless

      # Concludes message
      Rails.logger.info ""
      Rails.logger.info e.message

      raise "Failed to get browser from Browserstack - #{e.message}"

    end # end error handling
  end # end method

end # end class BrowserFactory