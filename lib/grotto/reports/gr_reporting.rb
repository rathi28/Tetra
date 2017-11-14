# Parent Class for all Reports
# Contains the Test details applicable to all test cases
require Rails.root.join('app/models/test_run.rb')
require Rails.root.join('app/models/testrun.rb')
require Rails.root.join('app/models/test_suites.rb')

module GRReporting

  ##
  # gets the current time in PST timezone
  # @return 
  def self.get_pst()
    return (Time.now.getutc - 7*60*60).to_s.gsub('UTC','PST')
  end

  ##
  # report for general use, imports other reports if needed.
  # its upload class only applies to offercode/buyflow tests
  # The other tests handle their own reporting in their upload methods
  class Report
    attr_accessor :id             # Testcase id
    attr_accessor :title          # Testcase Title
    attr_accessor :author         # Author who issued the command for the testcase
    attr_accessor :status         # Pass/Fail status for the test
    attr_accessor :runtime        # Runtime for the test case
    attr_accessor :datetime       # datetime test run for the test case
    attr_accessor :environment    # Test Environment [dev, stg, qa, prod]
    attr_accessor :browser        # Browser
    attr_accessor :os             # Operating System/Device
    attr_accessor :grcid          # Campaign Code Identifier
    attr_accessor :url            # URL for the test case
    attr_accessor :test_id        # Test ID for the test (script run by test)
    attr_accessor :buyflow_report # Buyflow Report (optional)
    attr_accessor :pixel_report   # Pixel Test Report (optional)
    attr_accessor :uci_report     # UCI Report (optional)
    attr_accessor :suite_id       # Test Suite ID
    attr_accessor :notes          # notes and issues
    attr_accessor :platform       # driverplatform
    attr_accessor :driver         # browserfactory driver
    attr_accessor :notes          # notes and issues
    attr_accessor :backtrace      # Backtrace of any error
    attr_accessor :remote_url     # Remote Machine (if applicable)



    def initialize(
      id: nil,
      title: nil,
      author: nil,
      status: nil,
      runtime: nil,
      environment: nil,
      browser: nil,
      os: nil,
      grcid: nil,
      url: nil,
      test_id: nil,
      suite_id: 0,
      notes: ''
      )

      @id           = id
      @title        = title
      @author       = author
      @status       = status
      @runtime      = runtime
      @environment  = environment
      @browser      = browser
      @os           = os
      @grcid        = grcid
      @url          = url
      @test_id      = test_id
      @suite_id     = suite_id
      @notes        = notes
      @datetime     = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    end

    ##
    # uploads results to the database
    # @return Testrun uploaded results
    def upload()  
      #key = '1tntGgq7oHfEWt89AakaPzitEyuPR4Z8sL_nrD6pcRWg'
      #document = connect_to_sheet(document_key: key)

      # datetime of test completetion.
      @datetime     = Time.now.strftime('%Y-%m-%d %H:%M:%S')


      # storage hash for all test values
      report_package = {
        "Test Name"         => @title,
        "Ran by"            => @author,
        "Pass/Fail"         => @status,
        "Runtime (minutes)" => @runtime,
        "Env"               => @environment,
        "Platform"          => @os,
        "Browser"           => @browser,
        "Campaign"          => @grcid,
        "Test Run ID"       => @test_id,
        "DateTime (PST)"    => @datetime,
      }

      # import the buyflow report if present to the report package
      if(@buyflow_report)
        report_package = report_package.merge @buyflow_report.upload()
      end

      # import the UCI report if present to the report_package
      if(@uci_report)
        report_package = report_package.merge @uci_report.upload()
      end

      # get or create a test run for this report
      if id.nil?
        run = Testrun.new() 
      else
        run = Testrun.find(id)
      end
      
      # copying values from the report_package to the test run object
      run['test name']            = report_package["Test Name"].to_s
      run['runtime']              = report_package["Runtime (minutes)"].to_s
      run['result']               = report_package["Pass/Fail"].to_s
      run['Brand']                = report_package["Brand"].to_s if report_package["Brand"]
      run['Campaign']             = report_package["Campaign"].to_s
      run['Platform']             = report_package["Platform"].to_s if report_package["Platform"]
      run['Browser']              = report_package["Browser"].to_s if report_package["Browser"]
      run['Env']                  = report_package["Env"].to_s
      run['ExpectedOffercode']    = report_package["Expected Offercode"].to_s
      run['ActualOffercode']      = report_package["Actual Offercode"].to_s
      run['Expected UCI']         = report_package["Expected UCI"].to_s
      run['UCI HP']               = report_package["UCI - HP"].to_s
      run['UCI OP']               = report_package["UCI - OP"].to_s
      run['UCI CP']               = report_package["UCI - CP"].to_s
      run['ConfirmationNum']      = report_package["Confirmation # (confirmation page)"].to_s
      run['DateTime']             = report_package["DateTime (PST)"].to_s
      run['test_suites_id']       = suite_id.to_s   # recording suite id
      run['Notes']                = @notes.to_s     # recording error messages
      run['Backtrace']            = @backtrace.to_s # recording backtrace value
      run['url']                  = @url.to_s       # recording url
      run["status"]               = "Complete"      # recording test run complete status
      run["remote_url"]           = @remote_url     # recording the Selenium Grid URL
      run["confoffercode"]        = report_package['confoffercode']
      run["vitamincode"]          = report_package['vitamincode']
      run['vitamin_pricing']      = report_package['vitamin_pricing']
      run['cart_language']        = report_package['cart_language']
      run['cart_title']           = report_package['cart_title']
      run['total_pricing']        = report_package['total_pricing']
      run['subtotal_price']       = report_package['subtotal_price']
      run['saspricing']           = report_package['saspricing']
      run['billaddress']          = report_package['billaddress']
      run['shipaddress']          = report_package['shipaddress']
      run['billemail']            = report_package['billemail']
      run['billname']             = report_package['billname']
      run['vitaminexpected']      = report_package['expectedvitamin']
      run['vitamin_description']  = report_package['vitamin_description']
      run['vitamin_title']        = report_package['vitamin_title']
      run['sas_kit_name']         = report_package['sas_kit_name']
      run['cart_quantity']         = report_package['cart_quantity']
      run['Standard']             = report_package['shipping_standard']
      run['Rush']                 = report_package['shipping_rush']
      run['Overnight']            = report_package['shipping_overnight']
      run['continuitysh']         = report_package['continuity_shipping']
      run['confpricing']          = report_package['confpricing']
      run['confvitaminpricing']   = report_package['confvitaminpricing']
      run['shipping_conf']        = report_package['shipping_conf']
      run['shipping_conf_val']    = report_package['shipping_conf_val']
      run['conf_kit_name']        = report_package['conf_kit_name']
      run['conf_vitamin_name']    = report_package['conf_vitamin_name']
      run['selected_shipping']    = report_package['selected_shipping']
      run['uci_sas']              = report_package['uci_sas']
      run['kitnames']             = report_package['kitnames']
      run['sasprices']            = report_package['sasprices']
      run['lastpagefound']        = report_package['lastpagefound']

      # recording results in database
      run.save!

      # returns the Testrun
      return run

    end

    ##
    # debug printing statement
    # @deprecated No longer in use, needs to be updated if resurrected
    def to_s()
      string = ""
      string += """
      Test Report
      ---
      Title:          #{@title}
      Author:         #{@author}
      Status:         #{@status}
      DateTime:       #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}
      Runtime:        #{@runtime}
      Environment:    #{@environment}
      Browser:        #{@browser}
      OS/Device:      #{@os}
      Grcid:          #{@grcid}
      URL:            #{@url}
      TestID:         #{@test_id}
      """
      string += @buyflow_report.to_s if(@buyflow_report)
      string += @uci_report.to_s if(@uci_report)

      return string
    end
  end

  # Class for storing individual pixel results
  # Currently only used to store confirmation number for pixel tests
  # This class could be replaced with a class variable now, but leaving it for now as that's not a priority
  class PixelReport
    attr_accessor :confirmation_number # confirmation number pulled from end of confirmation pixel tests
    attr_accessor :pixelresults # former container for pixel results from pixel tests, now stored as indpendent object in the test case.
    
    def initialize()
      @pixelresults = []
      @confirmation_number = nil
    end
  end

  # Report Class for Buyflow Report objects
  # Catches all data for uploading to buyflow database
  class BuyflowReport
    attr_accessor :brand                # The Brand of Campaign being tested
    attr_accessor :expected_offer_code  # The Expected Offercode for a Buyflow Test
    attr_accessor :offer_code           # The Actual Offercode for a Buyflow Test
    attr_accessor :vitamin_code         # The Actual Vitamin Offercode for a Buyflow Test
    attr_accessor :confirmation_number  # Confirmation Number for the Order Placed
    attr_accessor :confoffercode        # Confirmation Page Offercode
    attr_accessor :vitamin_pricing      # price of vitamin if default offercode
    attr_accessor :cart_language        # cart description on order page
    attr_accessor :cart_title           # cart title on order page
    attr_accessor :total_pricing        # total price on order page
    attr_accessor :subtotal_price       # subtotal price on order page
    attr_accessor :saspricing           # sas pricing correct (boolean)
    attr_accessor :billaddress          # billing address
    attr_accessor :shipaddress          # shipping address
    attr_accessor :billemail            # billing email
    attr_accessor :billname             # billing address name
    attr_accessor :expectedvitamin      # vitamin offercode expected for this page
    attr_accessor :vitamin_language     # vitamin description on order form page
    attr_accessor :vitamin_title        # vitamin title on order form page
    attr_accessor :sas_kit_name         # sas kit name correct boolean
    attr_accessor :cart_quantity         # quantity value in cart (should equal 1)
    attr_accessor :shipping_standard    # shipping cost for standard rate (AKA priority)
    attr_accessor :shipping_rush        # shipping for rush rate
    attr_accessor :shipping_overnight   # shipping for overnight rate
    attr_accessor :continuity_shipping  # shipping for continued orders
    attr_accessor :confoffercode        # confirmation page offer code
    attr_accessor :confpricing          # confirmation page pricing
    attr_accessor :confvitaminpricing   # confiramtion page vitamin price
    attr_accessor :shipping_conf        # did the confirmation page value match selected for shipping? boolean
    attr_accessor :conf_kit_name        # confirmation page kit name for main product
    attr_accessor :conf_vitamin_name    # confirmation page vitamin title
    attr_accessor :shipping_conf_val    # shipping price on confirmation page (duplicate?)
    attr_accessor :selected_shipping    # selected shipping from order page
    attr_accessor :kitnames             # list of kits from the SAS page steps
    attr_accessor :sasprices            # list of prices from the SAS page steps
    attr_accessor :lastpagefound        # Last page recorded before test completed


    def initialize(
      brand: nil,
      expected_offer_code: nil,
      offer_code: nil,
      vitamin_code: nil,
      confirmation_number: nil
      )
      @brand                = brand
      @expected_offer_code  = expected_offer_code
      @offer_code           = offer_code
      @vitamin_code         = vitamin_code
      @confirmation_number  = confirmation_number
    end

    ##
    # Debug statement, prints out the values in report prior to uploading
    #  @deprecated Badly needs updating and is not used currently.
    def to_s
      return """
      Buyflow Results
      ---
      Brand:                  #{@brand}
      Expected Offer Code:    #{@expected_offer_code}
      Actual Offer Code:      #{@offer_code}
      Vitamin Code:           #{@vitamin_code}
      Confirmation Number:    #{@confirmation_number}
      """
    end
    # constructs the report_package for uploading the data about test results.
    def upload()
      report_package = {
        'Expected Offercode'                  => @expected_offer_code,
        'Actual Offercode'                    => @offer_code,
        'Brand'                               => @brand,
        'vitamincode'                         => @vitamin_code,
        'Confirmation # (confirmation page)'  => @confirmation_number,
        'confoffercode'                       => @confoffercode,
        'vitamin_pricing'                     => @vitamin_pricing,
        'cart_language'                       => @cart_language,
        'cart_title'                          => @cart_title,
        'total_pricing'                       => @total_pricing,
        'subtotal_price'                      => @subtotal_price,
        'saspricing'                          => @saspricing,
        'billaddress'                         => @billaddress,
        'shipaddress'                         => @shipaddress,
        'billemail'                           => @billemail,
        'billname'                            => @billname,
        'expectedvitamin'                     => @expectedvitamin,
        'vitamin_description'                 => @vitamin_language,
        'vitamin_title'                       => @vitamin_title,
        'sas_kit_name'                        => @sas_kit_name,
        'cart_quantity'                       => @cart_quantity,
        'shipping_standard'                   => @shipping_standard,
        'shipping_rush'                       => @shipping_rush,
        'shipping_overnight'                  => @shipping_overnight,
        'continuity_shipping'                 => @continuity_shipping,
        'confoffercode'                       => @confoffercode,
        'confpricing'                         => @confpricing,
        'confvitaminpricing'                  => @confvitaminpricing,
        'shipping_conf'                       => @shipping_conf,
        'conf_kit_name'                       => @conf_kit_name,
        'conf_vitamin_name'                   => @conf_vitamin_name,
        'shipping_conf_val'                   => @shipping_conf_val,
        'selected_shipping'                   => @selected_shipping,
        'kitnames'                            => @kitnames,
        'sasprices'                           => @sasprices,
        'lastpagefound'                       => @lastpagefound,
      }

      return report_package
    end
  end

  # Report Class for UCI Report objects
  # At this point, this is a glorified Hash for UCI codes, but is being left in case there is a used for it in the future and also to enforce names for fields.
  # Possibly used in other test cases other than UCI/Vanity, would need to check the code to be sure.
  class UCIReport
    attr_accessor :expected_uci         # The Expected UCI for a test
    attr_accessor :uci_mp               # The Actual UCI for a Marketing Module (Homepage/Landing page)
    attr_accessor :uci_op               # The Actual UCI for an Order Page/Cart
    attr_accessor :uci_cp               # The Actual UCI for a Confirmation Page
    attr_accessor :uci_sas               # The Actual UCI for a SAS Page

    def initialize(
      expected_uci: nil,
      uci_mp: nil,
      uci_op: nil,
      uci_cp: nil,
      uci_sas: nil
      )
      @expected_uci         = expected_uci
      @uci_mp               = uci_mp
      @uci_op               = uci_op
      @uci_cp               = uci_cp
      @uci_sas              = uci_sas
    end

    # Prints contents of report.
    # @deprecated Unused debug function - if someone wants to resurrect this function and update for new values they can. 
    def to_s
      return """
      UCI Results
      ---
      Expected UCI:           #{@expected_uci}
      UCI Landing Page:       #{
        if(@uci_mp.nil?)
          "Nil"
        else
          if @uci_mp.empty?
            "None"
          else
            @uci_mp
          end
        end
      }
      UCI Order Page:         #{
        if(@uci_op.nil?)
          "Nil"
        else
          if @uci_op.empty?
            "None"
          else
            @uci_op
          end
        end
      }
      UCI Confirmation Page:  #{
        if(@uci_cp.nil?)
          "Nil"
        else
          if @uci_cp.empty?
            "None"
          else
            @uci_cp
          end
        end
      }
      """
    end

    ##
    # Constructs the report_package for merging into an upload action for posting to database
    # @deprecated no longer needed as direct inserting into TestRun through the test cases upload function works better.

    def upload
      report_package = {
        'Expected UCI' => @expected_uci,
        'UCI - HP' => @uci_mp,
        'UCI - OP' => @uci_op,
        'UCI - CP' => @uci_cp,
        'uci_sas' => @uci_sas,
      }
      return report_package

    end
  end
end
