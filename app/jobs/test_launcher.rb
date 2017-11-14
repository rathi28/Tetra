# import grotto files
require_relative Rails.root.join("lib/grotto/import.rb")
require_relative Rails.root.join("lib/grotto/browser/grid_utilities.rb")
##
# This Class is used to manage testcase workers, start tests, clear orphan testcases, and add work to a queue
# If you need to make changes to how the tests are executed and initialized, check here first, and then dive into your specific test class for more details.
# This and the two helper methods should be the only files in the App directory used in the test execution process.

class TestLauncher
    # location: tetra/lib/grotto/better_errors.rb
    include ::BetterErrors

    # includes for test creation functions

    # location: tetra/app/helpers/testsuites_helper.rb
    include ::TestsuitesHelper

    # location: tetra/app/helpers/pixels_helper.rb
    include ::PixelsHelper

    # whether or not the hub is currently available
    attr_accessor :hub_up

    # the name of this worker process
    attr_accessor :worker

    # the priority for running tests for this particular worker
    attr_reader :priority

    # @!group Test Worker Management

    ##
    # Clears the old test cases reserved in case of a worker going down/system reset 
    # @param [string] worker The Worker Process you want to find reserved test cases from
    # @example Clear a workers old test cases
    #   TestLauncher.reset_old_tests(2)
    # @note This should be run if you are bringing a particular worker down to clear its old work.
    def reset_old_tests(worker)
        # load Grotto 
        # @todo - I don't think this is actually needed. Will pull out if not.
        require_relative Rails.root.join("lib/grotto/import.rb")
        
        # Pull locked test cases for given worker
        previous_allocated_to_worker = Testrun.where(:status => "Not Started", :workerassigned => worker)


        begin
            # iterate through all the test cases found
            previous_allocated_to_worker.each do |testcase|
                # clear the lock on the testcase
                testcase[:status] = "Not Started"
                testcase[:workerassigned] = nil
                # save the reset
                testcase.save!
            end
        rescue => e
            # print out any errors found, but continue running code
            Rails.logger.info e.message
            # detailed line references
            Rails.logger.info e.backtrace.to_s
        end

        previous_allocated_to_worker = TestRun.where(:status => "Not Started", :workerassigned => worker)
        begin
            # iterate through all the test cases found
            previous_allocated_to_worker.each do |testcase|
                # clear the lock on the testcase
                testcase[:status] = "Not Started"
                testcase[:workerassigned] = nil
                # save the reset
                testcase.save!
            end
        rescue => e
            # print out any errors found, but continue running code
            Rails.logger.info e.message
            # detailed line references
            Rails.logger.info e.backtrace.to_s
        end
    end

    ##
    # initiates the checked for both daily and weekly tests, adding them to the database if needed
    def check_schedule()
        create_daily_tests()
        create_weekly_tests()
    end


    ##
    # Clears the old test cases reserved in case of a worker going down/system reset 
    # @param [string] worker_name The Worker Process you want to find reserved test cases from
    # @return [hash] Sorted hash object of test types to be run
    def test_order(worker_name = 1)

        # if running on isolated UI, ignore priority and run only isolated tests
        if(worker_name.to_s.include?("isolate"))
            return {"isolated" => 1}
        end

        # initialize hash
        order               = {}

        begin
            # get record
            record              = Worker.where(name: worker_name).first

            # pulling relevant fields into hash, unless they are ranked 0
            order['pixel']      = record.pixel if record.pixel != 0
            order['scheduled']  = record.scheduled if record.scheduled != 0
            order['buyflow']    = record.buyflow if record.buyflow != 0

            # sort into sorted array
            order_array = order.sort_by{|k, v| v}

            #convert back to hash for reading
            test_priority = Hash[order_array]
        rescue => e

            # catch and handle error
            Rails.logger.info "Error - #{e.message}"
            Rails.logger.info "Could not find record for worker - using default order"

            # use default hash
            test_priority = {"scheduled" =>1, "buyflow" => 2, "pixel" => 3}
        end

        # return to user
        return test_priority
    end

    ##
    # Checks for new test runs
    # @param [integer] worker The Worker Process you want to add work to
    # @example Hand a specific worker new work
    #   TestLauncher.new().delay(:queue => '2').run(2)

    def run(worker = 1)
        Rails.logger = Logger.new("#{Rails.root.to_s}/log/worker-#{worker}.log", 1, 5242880)
        Delayed::Worker.logger = Rails.logger
        Delayed::Worker.logger.level = Logger::DEBUG
        # label the process with worker title
        puts "Worker #{worker} process"
        
        # set the worker attribute to the input value
        @worker = worker
        # label if testing should continue (basically should test forever until the worker quits, could be used to attach a database value and terminate workers remotely.)
        testing = true
        
        while(testing == true)
            @priority = test_order(@worker)
            reset_old_tests(@worker)
            check_schedule() if(@worker == 1)
            try_different_browser = false
            @hub_up = true
            # mark this process name
            #Rails.logger.info "--- worker #{@worker} ---"
            current_test = nil
            current_tests = nil
            sleep(2)
            #Rails.logger.info "Checking for tests"

            # set to empty hash
            current_tests = find_current_tests(@priority)
            
            begin
                if(current_tests.first().nil?)
                    #Rails.logger.info "No Tests to run"
                    raise "No Tests to run"
                else
                    Rails.logger.info "- Getting first test from list"
                    current_test = current_tests.first
                    Rails.logger.info "- No Tests to run"
                    begin
                        current_test_driver = current_test.Driver
                    rescue
                        current_test_driver = current_test.driver
                        current_test_driver = "firefox" if current_test_driver.nil?

                    end
                    Rails.logger.info "- Checking for browser availability"

                    begin
                        GridUtilities.browser_available(host: Grid_Processes.where('role = ?', "hub").first.ip, port: Grid_Processes.where('role = ?', "hub").first.port, driver_name: current_test_driver) if(current_test_driver.include?('grid'))
                    rescue => e
                        Rails.logger.info e.message
                        Rails.logger.info e.backtrace
                        @hub_up = false
                    end

                    if(@hub_up)
                        if current_test_driver.include?('grid')
                            if(GridUtilities.browser_available(host: Grid_Processes.where('role = ?', "hub").first.ip, port: Grid_Processes.where('role = ?', "hub").first.port, driver_name: current_test_driver))
                                if(current_test["workerassigned"] == nil)
                                    current_test["workerassigned"] = @worker
                                    current_test.save!
                                end
                                puts "- Worker #{@worker} can run test ##{current_test.id}"
                                if(current_test["testtype"].downcase == 'buyflow')
                                    puts "- Running Order Purchase TestCase #{current_test['id']}"
                                    buyflow(current_test)
                                end
                                if(current_test["testtype"].downcase.include?('pixel'))
                                    puts "- Running Pixels TestCase #{current_test['id']}"
                                    pixel(current_test)
                                end
                                if(current_test["testtype"].downcase.include?('vanity'))
                                    puts "- Running Vanity TestCase #{current_test['id']}"
                                    vanity(current_test)
                                end
                                if(current_test["testtype"].downcase.include?('uci'))
                                    puts "- Running UCI TestCase #{current_test['id']}"
                                    uci(current_test)
                                end
                                if(current_test["testtype"].downcase.include?('seo'))
                                    puts "- Running seo TestCase #{current_test['id']}"
                                    seo(current_test)
                                end
                            else
                                Rails.logger.info "No browser available for this test case"
                                raise "no_browser"
                            end
                        else
                            if(current_test["workerassigned"] == nil)
                                current_test["workerassigned"] = @worker
                                current_test.save!
                            end
                            Rails.logger.info "- Worker #{@worker} can run test ##{current_test.id}"
                            if(current_test["testtype"].downcase == 'buyflow')
                                puts "- Running Order Purchase TestCase #{current_test['id']}"
                                buyflow(current_test)
                            end
                            if(current_test["testtype"].downcase.include?('pixel'))
                                puts "- Running Pixels TestCase #{current_test['id']}"
                                pixel(current_test)
                            end
                            if(current_test["testtype"].downcase.include?('vanity'))
                                puts "- Running Vanity TestCase #{current_test['id']}"
                                vanity(current_test)
                            end
                            if(current_test["testtype"].downcase.include?('uci'))
                                puts "- Running UCI TestCase #{current_test['id']}"
                                uci(current_test)
                            end
                            if(current_test["testtype"].downcase.include?('seo'))
                                puts "- Running seo TestCase #{current_test['id']}"
                                seo(current_test)
                            end
                        end
                    end
                    current_test = nil
                end
            rescue ActiveRecord::StaleObjectError => e
                Rails.logger.info e.message
                Rails.logger.info e.backtrace if e.backtrace
            rescue Net::ReadTimeout => e
                Rails.logger.info "Caught Net::ReadTimeout"
                reset_old_tests(@worker)
                # catch browser communication failures
                Rails.logger.info e.message
                Rails.logger.info e.backtrace if e.backtrace
                # tell this worker to try another browser for now
                current_tests = Testrun.where(:status => "Not Started", :workerassigned => nil).where.not(:Driver => current_test.Driver)
                current_test = nil
                #try_different_browser = true
                retry
            rescue ActiveRecord::RecordNotFound => e
                Rails.logger.info "Caught RecordNotFound"
                Rails.logger.info "#{e.message}"
                sleep(2)
            rescue => e
                if(e.message == "no_browser")
                    puts "Caught no_browser"
                    Rails.logger.info 'No #{current_test.Driver} browser was found for this test run.'
                    current_tests = Testrun.where(:status => "Not Started", :workerassigned => nil).where.not(:Driver => current_test.Driver)
                    current_test = nil
                    try_different_browser = true
                elsif(e.message == "No Tests to run")
                    puts "Caught 'No Tests to run'"
                    try_different_browser = false
                    sleep(2)
                else
                    Rails.logger.info "Run Completed"
                    try_different_browser = false
                    Rails.logger.info "#{e.message}"
                    Rails.logger.info "#{e.backtrace}"
                    sleep(2)
                    if(current_test)
                        current_test["result"]  = "Fail"
                        current_test["status"]  = "Complete"
                        current_test["Notes"]   = e.message + " \n" + e.backtrace[0]+ " \n" + e.backtrace[1]
                        current_test.save!
                        # update_suite(current_test.test_suites) 
                    end
                end
            end
            begin
                Delayed_Job.where(:queue => worker).destroy_all
            rescue => e
                Rails.logger.info e.message
            end
            TestLauncher.new.delay(:queue => worker).run(worker)
            testing == false
        end
    end

    def find_current_tests(priority)
        # set to empty hash
        current_tests = []
        collect_tests = []
        # iterate through order in priority order to find tests to run
        # NOTE - This will need to be updated to request specific test types later when we add UCI/Vanity to stack of options for TestRun type tests
        priority.each do |test_variety, rank|
            case test_variety
            when "isolated"
                # This is for on demand priority testing which needs to be run immediately. Should be used sparingly to keep isolated queue open for important tests/retests
                if current_tests.empty?
                    current_tests = Testrun.test_ondemand_to_be_run().where("isolated" => 1)
                end

                if current_tests.empty?
                    current_tests = TestRun.test_ondemand_to_be_run().where("isolated" => 1)
                end

                return current_tests
            when "buyflow"
                current_tests = []
                current_tests = Testrun.test_ondemand_to_be_run()
                if(!current_tests.empty?)
                    current_tests.each do |test|
                        collect_tests.push(test)
                    end
                end
                current_tests.clear

            when "pixel"

                current_tests = []
                current_tests = TestRun.test_ondemand_to_be_run()
                if(!current_tests.empty?)
                    current_tests.each do |test|
                        collect_tests.push(test)
                    end
                end
                current_tests.clear
                
            when "scheduled"
                priority.each do |test_variety_schedule, rank|

                    case test_variety_schedule
                    when "buyflow"
                        current_tests = []
                        current_tests = Testrun.test_scheduled_to_be_run()
                        if(current_tests.length > 0)
                            current_tests.each do |test|
                                collect_tests.push(test)
                            end
                        end
                        current_tests.clear
                    when "pixel"
                        current_tests = []
                        current_tests = TestRun.test_scheduled_to_be_run()
                        if(current_tests.length > 0)
                            current_tests.each do |test|
                                collect_tests.push(test)
                            end
                        end
                        current_tests.clear
                    end 
                    # end of schedule case iterations

                end 
                # end of schedule priority iterations      

            end 
            # end of case iterations

        end 
        # end of priority iterations

        # return collected tests
        return collect_tests
    end

    # @!endgroup 

    # @!group Scheduled Test Methods

    ##
    # Initialize a scheduled test run
    # @param [RecurringSchedule] tests Test Record to be run
    def setup_scheduled_test(tests)
        tests.each do |test|
            testtype = test['testtype'].downcase
            if(testtype == "buyflow" || testtype == "offercode")
                params = {}
                params[:brand]              = test.brand
                params[:campaign]           = test.grcid
                params[:server]             = test.environment
                params[:realm]              = test.realm
                params[:browser]            = test.driver
                params[:platform]           = test.platform
                params[:custom_url]         = test.customurl
                params[:custom_offer]       = test.customoffer
                params[:emailnotification]  = test.email
                params[:scheduledate]       = Time.now.to_s
                params[:scheduleid]         = test.id
                params[:email_random]       = true
                # params[:is_upsell]          = test.is_upsell
                # puts params[:is_upsell]
                create_test(params, testtype)
                test.lastrundate = Date.today
                test.save!
            end
            if(testtype == "pixels" || testtype == "pixel")
                params = {}
                params[:browser]            = test.driver
                params[:platform]           = test.platform
                params[:testsuite]          = test.pixel_suite
                params[:email]              = test.email
                params[:scheduledate]       = Time.now.to_s
                params[:scheduleid]         = test.id
                params[:email_random]       = true
                generate_pixel_test(params, 'Scheduled')
                test.lastrundate = Date.today
                test.save!
            end
            if(testtype == "vanity")
                params = {}
                params[:browser]            = test.driver
                params[:driver]            = test.driver
                params[:platform]           = test.platform
                params[:testsuite]          = test.pixel_suite
                params[:email]              = test.email
                params[:scheduledate]       = Time.now.to_s
                params[:scheduleid]         = test.id
                params[:email_random]       = true
                generate_vanity_test(params, 'Scheduled')
                test.lastrundate = Date.today
                test.save!
            end
            if(testtype == "uci")
                params = {}
                params[:browser]            = test.driver
                params[:driver]            = test.driver
                params[:platform]           = test.platform
                params[:testsuite]          = test.pixel_suite
                params[:email]              = test.email
                params[:scheduledate]       = Time.now.to_s
                params[:scheduleid]         = test.id
                params[:email_random]       = true
                generate_uci_test(params, 'Scheduled')
                test.lastrundate = Date.today
                test.save!
            end
            if(testtype == "seo")
                params = {}
                custom_settings = YAML.load(test.custom_settings)
                params[:browser]            = test.driver
                params[:driver]             = test.driver
                params[:platform]           = test.platform
                params[:testsuite]          = test.pixel_suite
                params[:email]              = test.email
                params[:scheduledate]       = Time.now.to_s
                params[:scheduleid]         = test.id
                params[:email_random]       = true                
                if(custom_settings["homepageseocheck"])
                params[:homepageseocheck]       = custom_settings["homepageseocheck"]
                else
                params[:homepageseocheck]       = 0
                end
                if(custom_settings["saspageseocheck"])
                params[:saspageseocheck]       = custom_settings["saspageseocheck"]
                else
                params[:saspageseocheck]       = 0
                end                
                if(custom_settings["cartpageseocheck"])
                params[:cartpageseocheck]       = custom_settings["cartpageseocheck"]
                else
                params[:cartpageseocheck]       = 0
                end    
                if(custom_settings["confirmationseocheck"])
                params[:confirmationseocheck]       = custom_settings["confirmationseocheck"]
                else
                params[:confirmationseocheck]       = 0
                end
                if(custom_settings["robottxtseocheck"])
                params[:robottxtseocheck]       = custom_settings["robottxtseocheck"]
                else
                params[:robottxtseocheck]       = 0
                end
                if(custom_settings["sitemapxmlseocheck"])
                params[:sitemapxmlseocheck]       = custom_settings["sitemapxmlseocheck"]
                else
                params[:sitemapxmlseocheck]       = 0
                end                
                generate_seo_test(params, 'Scheduled')
                test.lastrundate = Date.today
                test.save!
            end
        end
        return true
    end

    ##
    # This function is run by the primary worker (usually known as '1') and creates any daily test runs needed at time they are to be run.
    def create_daily_tests()

        Rails.logger.info "Checking for Daily test runs"

        # get instances of a daily test run
        tests_to_add_to_stack = RecurringSchedule.get_daily_tests()
        setup_scheduled_test(tests_to_add_to_stack)
    end

    ##
    # This function is run by the primary worker (usually known as '1') and creates any weekly test runs needed at time they are to be run.
    def create_weekly_tests()

        Rails.logger.info "Checking for Weekly test runs"

        # get instances of a weekly test run
        tests_to_add_to_stack = RecurringSchedule.get_weekly_tests_for_today()
        setup_scheduled_test(tests_to_add_to_stack)
    end
    # @!endgroup






    # @!group Test Case Launching Methods

    ##
    # Test Case launcher for pixel tests, generates the test run object from record and runs it.
    #
    def pixel(testrun)
        # pull the pixel suite data
        test_obj = GRTesting::PixelTest.new(title: testrun['test name'], browser: testrun['Driver'], pixelhash: testrun.test_steps, id: testrun.id)
        
        # Add Metadata to report object
        test_obj.report.author      = "Automation"
        test_obj.report.environment = testrun['Env']

        # Add the test settings to the test object
        test_obj.testtype = testrun['testtype']
        test_obj.platform = testrun['driverplatform']
        test_obj.custom_settings = YAML.load(testrun['custom_settings'])

        # get the testrun url
        target = testrun.url

        # get test suite
        suite = TestSuites.find(testrun.test_suites_id)

        # Add platform as a part of the campaign Hash object
        if(!suite.email_random)
            if(suite.emailnotification.include?(';'))
                conf_email_to_use = suite.emailnotification.split(';')[0].strip() 
            else
                conf_email_to_use = suite.emailnotification
            end
        else
           conf_email_to_use = Time.now.to_i.to_s + ".9fea5a75@mailosaur.in"
        end
        test_obj.email = conf_email_to_use
        
        # update its status for running suite
        suite.Status = "Running"

        # save the record
        suite.save!


        # if the target url is not properly formatted with protocol for testing
        if(!target.include?("http"))

            # prepend the default protocol and resume test
            url = "http://#{target}"

        else

            # set to url if correctly formatted
            url = target

        end

        # load the url into the test object
        test_obj.report.url         = url

        # run the test case
        test_obj.run()

        # check for needed updates to suite
        update_suite(suite)

        # return completed object for debugging or testing
        return test_obj
    end

    ##
    # Test Case launcher for vanity tests, generates the test run object from record and runs it.
    #
    def vanity(testrun)
        # get test suite
        suite = TestSuites.find(testrun.test_suites_id)
        # pull the vanity suite data
        test_obj = GRTesting::VanityTest.new(title: testrun['test name'], browser: testrun['driver'], validations: testrun.test_steps, id: testrun.id)
        # Add platform as a part of the campaign Hash object
        if(!suite.email_random)
            if(suite.emailnotification.include?(';'))
                conf_email_to_use = suite.emailnotification.split(';')[0].strip() 
            else
                conf_email_to_use = suite.emailnotification
            end
        else
           conf_email_to_use = Time.now.to_i.to_s + ".df8c8533@mailosaur.in"
        end
        test_obj.email = conf_email_to_use
        # Add Metadata to report object
        test_obj.report.author      = "Automation"
        test_obj.report.environment = testrun['Env']

        # Add the test settings to the test object
        test_obj.testtype = testrun['testtype']
        test_obj.platform = testrun['driverplatform']
        test_obj.browsertype = testrun['driver']
        
        begin
            test_obj.custom_settings = YAML.load(testrun['custom_settings'])
        rescue => e

        end

        # get the testrun url
        target = testrun.url

        # update its status for running suite
        suite.Status = "Running"

        # save the record
        suite.save!


        # if the target url is not properly formatted with protocol for testing
        if(!target.include?("http"))

            # prepend the default protocol and resume test
            url = "http://#{target}"

        else

            # set to url if correctly formatted
            url = target

        end

        # load the url into the test object
        test_obj.url         = url

        # run the test case
        test_obj.run()

        # check for needed updates to suite
        update_suite(suite)

        # return completed object for debugging or testing
        return test_obj
    end

    ##
    # Test Case launcher for uci tests, generates the test run object from record and runs it.
    #
    def uci(testrun)
        # get test suite
        suite = TestSuites.find(testrun.test_suites_id)

        # pull the uci suite data
        test_obj = GRTesting::UciTest.new(title: testrun['test name'], browser: testrun['driver'], validations: testrun.test_steps, id: testrun.id)
        # Add platform as a part of the campaign Hash object
        if(!suite.email_random)
            if(suite.emailnotification.include?(';'))
                conf_email_to_use = suite.emailnotification.split(';')[0].strip() 
            else
                conf_email_to_use = suite.emailnotification
            end
        else
           conf_email_to_use = Time.now.to_i.to_s + ".73b4fc03@mailosaur.in"
        end
        test_obj.email = conf_email_to_use

        # Add Metadata to report object
        test_obj.report.author      = "Automation"
        test_obj.report.environment = testrun['Env']

        # Add the test settings to the test object
        test_obj.testtype = testrun['testtype']
        test_obj.platform = testrun['driverplatform']
        test_obj.browsertype = testrun['driver']
        
        begin
            test_obj.custom_settings = YAML.load(testrun['custom_settings'])
        rescue => e

        end

        # get the testrun url
        target = testrun.url

        # get test suite
        suite = TestSuites.find(testrun.test_suites_id)

        # update its status for running suite
        suite.Status = "Running"

        # save the record
        suite.save!


        # if the target url is not properly formatted with protocol for testing
        if(!target.include?("http"))

            # prepend the default protocol and resume test
            url = "http://#{target}"

        else

            # set to url if correctly formatted
            url = target

        end

        # load the url into the test object
        test_obj.url         = url

        # run the test case
        test_obj.run()

        # check for needed updates to suite
        update_suite(suite)

        # return completed object for debugging or testing
        return test_obj
    end

    ##
    # Test Case launcher for seo tests, generates the test run object from record and runs it.
    #
    def seo(testrun)
        # get test suite
        suite = TestSuites.find(testrun.test_suites_id)
        # pull the seo suite data
        test_obj = GRTesting::SeoTest.new(title: testrun['test name'], browser: testrun['driver'], validations: testrun.test_steps, id: testrun.id)
        # Add platform as a part of the campaign Hash object
        if(!suite.email_random)
            if(suite.emailnotification.include?(';'))
                conf_email_to_use = suite.emailnotification.split(';')[0].strip() 
            else
                conf_email_to_use = suite.emailnotification
            end
        else
           conf_email_to_use = Time.now.to_i.to_s + ".d7f2d322@mailosaur.in"
        end

        test_obj.email = conf_email_to_use

        # Add Metadata to report object
        test_obj.report.author      = "Automation"
        test_obj.report.environment = testrun['Env']

        # Add the test settings to the test object
        test_obj.testtype = testrun['testtype']
        test_obj.platform = testrun['driverplatform']
        test_obj.browsertype = testrun['driver']
        
        begin
            test_obj.custom_settings = YAML.load(testrun['custom_settings'])
        rescue => e

        end

        # get the testrun url
        target = testrun.url

        

        # update its status for running suite
        suite.Status = "Running"

        # save the record
        suite.save!


        # if the target url is not properly formatted with protocol for testing
        if(!target.include?("http"))

            # prepend the default protocol and resume test
            url = "http://#{target}"

        else

            # set to url if correctly formatted
            url = target

        end

        # load the url into the test object
        test_obj.url         = url

        # run the test case
        test_obj.run()

        # check for needed updates to suite
        update_suite(suite)

        # return completed object for debugging or testing
        return test_obj
    end

    ##
    # Starts a new buyflow test for a particular testrun
    # @param [Testrun] testrun Testrun to be tested
    # @note This method breaks the campaign config into a hash, in order to be able to dynamically add some data at runtime
    #   This is important and should be remembered if reworking this method, or the tests won't run.
    def buyflow(testrun)
        # Pull this test runs test suite from model query
        suite = TestSuites.find(testrun['test_suites_id'])

        # Get the campaign data for the test run requested
        campaign_data = GRDatabase.get_campaign_data(testrun['Brand'], testrun['expectedcampaign'], testrun['Env'], testrun['DriverPlatform'], testrun['realm']).entries[0]

        # break the data into a Hash Object that the Campaign_Configuration variable needs for testing
        campaign_data = campaign_data.attributes
conf_email_to_use = ''
        # Add platform as a part of the campaign Hash object
        campaign_data.merge!({'platform' => testrun['Driver']})
        if(!suite.email_random)
            if(suite.emailnotification.include?(';'))
                conf_email_to_use = suite.emailnotification.split(';')[0].strip() 
            else
                conf_email_to_use = suite.emailnotification
            end
        else
           conf_email_to_use = Time.now.to_i.to_s + ".9e08e713@mailosaur.in"
        end

        
        campaign_data.merge!({'ConfEmailOverride' => conf_email_to_use})

        # vvv OBSOLETECODE vvv
        # offers = GRDatabase.get_offer_data(user_brand, user_campaign, platform)

        # Check for the existance of a expected offercode
        if !testrun['ExpectedOffercode'].strip.empty?

            # pull it from the test run if it exists
            offer_code = testrun['ExpectedOffercode']
        else

            # use the default value if present, if not the offercode will be nil
            offer_code = campaign_data["default_offercode"]
        end

        # Create a new test object which can be filled with test run data
        test_obj = GRTesting::BuyflowTest.new(title: testrun['test name'], browser: testrun['Driver'], configuration: campaign_data, offer_code: offer_code, id: testrun['id'])
        
        # Store the author of the test run 
        # @todo - use the given Ran_By
        # I don't even think this code is needed anymore, but I don't want to remove it for risk of breaking something. Will investigate if time, but for now its not hurting anything.
        test_obj.report.author      = "Automation"
        
        # The environment the test run is being run in
        test_obj.report.environment = testrun['Env']
        
        # The url that the test run is being run against
        test_obj.report.url         = URLFactory.generate_url(brand: campaign_data['Brand'], server: testrun['Env'], campaign: campaign_data['grcid'], test: (campaign_data['testenabled'] == 1)) if(testrun['url'].empty?)
        
        # Print out the url to be tested from URL factory
        test_obj.report.uci_report.expected_uci = campaign_data['UCI']
        Rails.logger.info "Url from URLFactory: #{test_obj.report.url}"
        
        # override of url (for realm 2 fix) from campaign configuration
        if(test_obj.report.environment == "prod")
            test_obj.report.url = campaign_data["produrl"] if(!campaign_data["produrl"].empty?)
            Rails.logger.info "OVERRIDE - Url from Campaign Configuration: #{test_obj.report.url}"
        else
            test_obj.report.url = campaign_data["qaurl"] if(!campaign_data["qaurl"].empty?)
            Rails.logger.info "OVERRIDE - Url from Campaign Configuration: #{test_obj.report.url}"
        end
        
        # Override url if testrun has a different url
        test_obj.report.url         = testrun['url'] if !testrun['url'].strip.empty?
        if(!test_obj.report.url.include?("http"))
            test_obj.report.url = "http://#{test_obj.report.url}"
        end
        #ssankara - adding to append mmcore.gm=2 for maxymiser test urls on Realm 2 (7 lines)        
        if(campaign_data["testenabled"] == 1 && !test_obj.report.url.include?("mmcore"))
            if(test_obj.report.url.include?("?"))
                test_obj.report.url = "#{test_obj.report.url}&mmcore.gm=2"
            else
                test_obj.report.url = "#{test_obj.report.url}/?mmcore.gm=2"
            end
        end
        Rails.logger.info "OVERRIDE Url from Test Run configuration: #{test_obj.report.url}"

        test_obj.report.suite_id    = testrun['test_suites_id']
        test_obj.report.buyflow_report.expected_offer_code = offer_code
        suite['Status'] = 'Running'
        suite.save! # 
        
        # runs the test in Grotto
        test_obj.run()  

        # Records test report to database
        test_obj.report.upload 

        # updates suite record in database
        update_suite(suite) 

    end
    # @!endgroup 





    # @!group Test Suite methods

    ##
    # Updates the suite with details of the run. Changes to calculated runtime, execution and pass/fail counts should be done here, and in the UI/controller files
    # @note Pixel and other future suites will be calculated through the UI and with queries more than through the test suite object. Remember this when making changes.

    def update_suite(suite)
        suite = TestSuites.find(suite.id)
        if suite.SuiteType != "pixels" && suite.SuiteType != "pixel" && suite.SuiteType != "vanity" && suite.SuiteType != "uci" && suite.SuiteType != "seo"
            passed_tests    = Testrun.where("test_suites_id" => suite.id, result: "pass")
            failed_tests    = Testrun.where("test_suites_id" => suite.id, result: "fail")
            remaining_tests = Testrun.where("test_suites_id" => suite.id, status: ["Not Started","Paused"])
            suite['Pass']   = passed_tests.length
            suite['Fail']   = failed_tests.length
            if remaining_tests.length == 0
                suite['Status'] = 'Complete'
                # Email Sending
                email = EmailBuilder.new(suite.emailnotification)
                email.title         = "#{suite.Brand} #{suite.Campaign} OfferCode Test #{suite.Environment} for #{suite.Browser}"
                email.body          = email.create_buyflow_email_body(suite.id)
                email.deliver
                testruns_run        = Testrun.where("test_suites_id" => suite.id)
                suite_runtime       = 0
                testruns_run.each do |run|
                    suite_runtime += run.runtime
                end
                suite['Runtime']    = suite_runtime
                suite.save!
            else
                suite['Status']     = 'Waiting' if suite['Status'] != "Paused"
            end
            suite.save!
        else
            passed_tests    = TestRun.where("test_suites_id" => suite.id, result: 1)
            failed_tests    = TestRun.where("test_suites_id" => suite.id, result: 0)
            remaining_tests = TestRun.where("test_suites_id" => suite.id, status: ["Not Started","Paused"])
            suite['Pass'] = passed_tests.size
            suite['Fail']   = failed_tests.size
            if remaining_tests.size == 0
                suite['Status'] = 'Complete'
                begin
                  # Email Sending
                  Rails.logger.info "sending email"
                  email = EmailBuilder.new(suite.emailnotification)
                  email.title         = "#{suite['Test Suite Name']} #{suite['SuiteType']} Test #{suite.Environment} for #{suite.Browser}"
                  email.body          = email.create_pixel_email(suite.id)
                  email.deliver
                rescue => e
                  Rails.logger.info e.message
                  log_error_to_database(e)
                end
                testruns_run        = TestRun.where("test_suites_id" => suite.id)
                suite_runtime       = 0
                begin
                    testruns_run.each do |run|
                        suite_runtime += run.runtime
                    end
                rescue => e
                    suite['Runtime']    = suite_runtime
                    suite.save!
                end
            else
                suite['Status']     = 'Waiting' if suite['Status'] != "Paused"
            end
            suite.save!
        end

    end
    # @!endgroup
end
