require 'pry'
require Rails.root.join('app/models/locator.rb')
class WebPage
  include BetterErrors
  attr_accessor :browser
  @locators = {}

  def initialize()
    @locators = {
      'email'             => {'type' => 'css', 'selector' => 'input.mail'},
      'phone'            => {'type' => 'css', 'selector' => 'input.phone'},
      'phone1'            => {'type' => 'css', 'selector' => '#phone1'},
      'phone2'            => {'type' => 'css', 'selector' => '#phone2'},
      'phone3'            => {'type' => 'css', 'selector' => '#phone3'},
      'firstname'         => {'type' => 'css', 'selector' => '#billFirstName'},
      'lastname'          => {'type' => 'css', 'selector' => '#billLastName'},
      'billAddress'       => {'type' => 'css', 'selector' => '#billAddress'},
      'billAddress2'      => {'type' => 'css', 'selector' => '#billAddress2'},
      'billCity'          => {'type' => 'css', 'selector' => '#billCity'},
      'billState'         => {'type' => 'css', 'selector' => '#billState'},
      'billZip'           => {'type' => 'css', 'selector' => '#billZip'},
      'creditCardNumber'  => {'type' => 'css', 'selector' => '#creditCardNumber'},
      'creditCardMonth'   => {'type' => 'css', 'selector' => '#creditCardMonth'},
      'creditCardYear'    => {'type' => 'css', 'selector' => '#creditCardYear'},
      'agreetoterms'      => {'type' => 'css', 'selector' => '#dwfrm_personinf_agree'},
    } # TODO Move to database
  end

  def return_first_text_from_array_locators(locators)
    locators.each do |locator|
      element = @browser.first(locator)
      if element
        return element.text()
      end
    end
    return nil
  end

  def return_first_text_from_query_locators(locators)
    locators.each do |locator|
      element = @browser.first(locator.css)
      if element
        return element.text()
      end
    end
    return nil
  end

  def check_if_page_ready
    timeout_var = 0
    while js_return("document.readyState") != 'complete' && timeout_var < 20
      Rails.logger.info "Waiting..."
      sleep(1)
      timeout_var += 1
    end
  end

  def browser=(browser)
    @browser = browser
    check_if_page_ready
  end

  #wrapper for common debugging functions
  def screenshot(location = 'screenshot/screen.png')
    Rails.logger.info 'saving screenshot'
    sleep(1)
    @browser.save_screenshot(location)
  end

  def url()
    return browser.url
  end

  def browser_name
    return @browser.driver.browser.capabilities[:browser_name].capitalize + " " + @browser.driver.browser.capabilities[:version]
  end

  def os_name
    user_agent = js_return "window.navigator.userAgent"
    begin
      return "Windows 8.1" if user_agent.include? "Windows NT 6.3"
      return "Windows 8" if user_agent.include? "Windows NT 6.2"
      return "Windows 7" if user_agent.include? "Windows NT 6.1"
      return "Windows Vista" if user_agent.include? "Windows NT 6.0"
      return "Windows Server 2003" if user_agent.include? "Windows NT 5.2"
      # TODO add handles for iPhone/iPad/Android
    rescue => e
      return "Unknown OS - Possibly Mobile"
    end

  end

  def click(type, locator)
    js_exec("$('#inqChatStage').hide()")
    check_if_page_ready
    attempts = 0
    begin
      browser.find(type, locator).click();
      sleep(1)
    rescue => e
      attempts += 1;
      if(attempts < 3)
        sleep(2);
        retry
      end
      raise e
    end
  end

  def click_if_exists(type, locator)
    attempts = 0
    begin
      element = browser.first(type, locator)
      element.click() if element
      sleep(1)
    rescue => e
      attempts += 1;
      if(attempts < 3)
        sleep(1);
        retry
      end
    end
  end



  def setElement(element, value)
    attempts = 0
    js_exec("$('#inqChatStage').hide()")
    begin
      element.set value
      if(element.value != value)
        raise FormFillException.new(element.native.attribute('id') + ' could not be set to ' + value.to_s)
      end
    rescue => e
      attempts  += 1
      if(attempts < 3)
        retry
      else
        raise e
      end
    end
  end

  def get_value
    attempts = 0
    begin
      yield
    rescue => e
      attempts  += 1
      if(attempts < 3)
        retry
      else
        raise e
      end
    end
  end

  def formfill(element,value)
    js_exec("$('#inqChatStage').hide()")
    attempts = 0
    begin
      yield
    rescue => e
      attempts  += 1
      if(attempts < 3)
        retry
      else
        raise e
      end
    end
  end

  def checkBox(element, value)
    js_exec("$('#inqChatStage').hide()")
    formfill(element, value) do
      element.set value
      if(element.checked? != value)
        raise FormFillException.new(element.native.attribute('id') + ' could not be set to ' + value.to_s)
      end
    end
  end

  def setElement(element, value)
    js_exec("$('#inqChatStage').hide()")
    formfill(element, value) do
      element.set value
      if(element.value != value)
        raise FormFillException.new(element.native.attribute('id') + ' could not be set to ' + value.to_s)
      end
    end
  end

  def dropdownselect(element, value)
    js_exec("$('#inqChatStage').hide()")
    formfill(element, value) do
      element.select value
      if(element.value != value)
        raise FormFillException.new(element.native.attribute('id') + ' could not be set to ' + value.to_s)
      end
    end
  end

  def title
    return @browser.title
  end

  def js_return(javascript)
    begin
      return @browser.evaluate_script(javascript)
    rescue => e
      Rails.logger.info e.message
      return nil
    end
  end

  def js_exec(javascript)
    begin
      return @browser.execute_script(javascript)
    rescue => e
      Rails.logger.info e.message
      return nil
    end
  end
end

class WebPage::FormFillException < RuntimeError

end
