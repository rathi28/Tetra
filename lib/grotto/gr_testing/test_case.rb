module GRTesting
  class TestCase
    include BetterErrors
    # codes for test results
    PASS = 1
    FAIL = 0

    
#    @errors     = nil
    @starttime  = nil

    attr_accessor :report
    attr_reader :id
    attr_reader :errors
    attr_accessor :email

    def get_browserdata
      return GRDatabase.get_browsertypes(@configuration['platform'])
    end

    def desktop?
      data    = get_browserdata
      result  = data.entries.first['device_type'] == 0
      return result
    end

    ##
    # Messy 
    def check_for_zid(url)
      uri_obj   = URI.parse(url)
      query_string = uri_obj.query
      return "false" if(query_string.nil?)
      parameters  = CGI::parse(query_string)
      zid_obj   = parameters['zid']

      return "false" if(zid_obj.nil?)
      return "false" if(zid_obj.empty?)

      zid     = zid_obj[0]
      
      zid_params  = zid.split('!')
      zid_config = {}
      zid_params.each do |item|
        pair = item.split(':')
        zid_config[pair[0]] = pair[1]
      end

      return "false" if(zid_config['grcid'].nil?)
      return "false" if(zid_config['dbi'].nil?)
      return "false" if(zid_config['dmti'].nil?)
      return "false" if(zid_config['dsti'].nil?)
      return "false" if(zid_config['dspp'].nil?)
      return "false" if(zid_config['dcti'].nil?)
      return "false" if(zid_config['mbi'].nil?)
      return "false" if(zid_config['mmti'].nil?)
      return "false" if(zid_config['msti'].nil?)
      return "false" if(zid_config['mcti'].nil?)
      @configuration['grcid']            = zid_config['grcid']
      if(desktop?)
        @configuration['DesktopBuyflow']       = zid_config['dbi']
        @configuration['DesktopHomePageTemplate']  = zid_config['dmti']
        @configuration['DesktopSASTemplate']     = zid_config['dsti']
        @configuration['DesktopSASPagePattern']  = zid_config['dspp']
        @configuration['DesktopCartPageTemplate']  = zid_config['dcti']
      else
        @configuration['DesktopBuyflow']       = zid_config['mbi']
        @configuration['DesktopHomePageTemplate']  = zid_config['mmti']
        @configuration['DesktopSASTemplate']     = zid_config['msti']
        @configuration['DesktopCartPageTemplate']  = zid_config['mcti']
      end
      return true
    end

    def initialize(title: "Testcase", id: nil)
      @errors = Array.new()
      @id = id
      @report = GRReporting::Report.new(title: title, id: id)
    end

    def run
      begin
        # run the test steps

        # prepare for the test
        before()
        # execute the test script
        execute()
      rescue => e

        # record all errors in error instance variable
        @errors.push(e)
        # Rails.logger.info e.message
        # Rails.logger.info e.backtrace
      end

      # clean up test resources and gather diagnostic data
      after()

      # upload results if collected
      upload_report()
    end

    def before
      puts "testcase before"
      Rails.logger.info "Executing Testcase '#{@report.title}'"
      @report.datetime = GRReporting.get_pst()
      @starttime = Time.now()
      # executes before anything else
      puts "done testcase before"
    end

    def execute
      # executes test case info
    end

    def after
      end_time       = Time.now()
      @report.runtime = end_time - @starttime
      # executes after everything else in case

      print  "Test - #{@report.id} - "
      if(@errors.length != 0)
        print "\e[31mFail\e[0m"
        @report.status = "Fail"
        Rails.logger.info "Test - #{@report.id} - Fail"
      else
        print "\e[32mPass\e[0m"
        @report.status = "Pass"
        Rails.logger.info "Test - #{@report.id} - Pass"
      end
      puts " - \e[36m #{@report.runtime} second(s)\e[0m"
      # print out error messages
      if(@errors.length != 0)
        print "Cause: "
        Rails.logger.info @errors.first.message
        Rails.logger.info @errors.first.backtrace if @errors.first.backtrace
        @report.notes = "#{@errors.first.message}"
        @report.backtrace = "#{@errors.first.backtrace.first}"
      end

      # optional debugging
      begin
        File.open("public/debug/#{id}.txt", "w") { |file|  
          file.write(@browser.html.to_s)
          file.close
        }  
      rescue => e
        e.display
      end

      begin
        @browser.save_screenshot("public/debug/#{id}.png")
      rescue => e
        e.display
      end
    end

    def upload_report
      # report test case result to server
      # Rails.logger.info @report.to_s
    end

    def fail(reason = 'Expected Data did not match Actual Data')
      raise reason
    end
  end
end