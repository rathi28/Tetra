module TestsuitesHelper
	##
	# TODO - DOCUMENT NEW METHOD
	def create_testrun(brand, offer, type, suite, params)
		new_run = Testrun.new('test_suites_id' => suite.id)
		new_run.Campaign 			= ''
		new_run['runby'] 			= suite['Ran By']
		new_run['result']	 		= 'waiting'
		new_run['test name'] 		= 'placeholder name'
		new_run.Env 				= params[:server]
		new_run['realm']			= params[:realm]
		new_run['Brand'] 			= brand
		new_run['Platform'] 		= ""
		new_run['Browser'] 			= params[:browser]
		new_run['Expected UCI'] 	= ""
		new_run['UCI HP'] 			= ""
		new_run['UCI OP'] 			= ""
		new_run['UCI CP'] 			= ""
		new_run['ConfirmationNum'] 	= ""
		new_run.url 				= params[:custom_url]
		new_run.ActualOffercode 	= ""
		new_run.Driver 				= params[:browser]
		new_run.ExpectedOffercode 	= offer['OfferCode']
		new_run.Notes = ""

		new_run.DriverPlatform 		= params[:platform]
		# The Following line should always be buyflow
		new_run.testtype 			= 'buyflow' 
		new_run.status 				= "Not Started"
		new_run.isolated = 1 if params[:isolated]
		new_run['expectedcampaign']	= params[:campaign]
		new_run['DateTime']         = suite['DateTime']
		new_run['scheduledate'] 	= params[:datetime] if(params[:datetime])
		new_run['scheduledate'] 	= params[:scheduledate].gsub(/ -[\d]+/,'') if(params[:scheduledate])
		new_run['is_upsell'] 			= params[:is_upsell] if(params[:is_upsell])
		begin
			if offer['OfferCode'].empty?

					campaign_data = nil

					begin
						# Get the campaign data for the test run requested
		        		campaign_data = GRDatabase.get_campaign_data(new_run['Brand'], new_run['expectedcampaign'], new_run['Env'], new_run['DriverPlatform'], new_run['realm']).entries[0]
		        	rescue => e

		        	end

	        		# break the data into a Hash Object that the Campaign_Configuration variable needs for testing
	        		campaign_data = campaign_data.attributes
	        		new_run.ExpectedOffercode = campaign_data["default_offercode"]
	   		end
		rescue => e
		end

		return new_run
	end

	def schedule_create(testtype, type, params)
		time 					= Time.parse(params["#{type}-time"])
		new_recur 				= RecurringSchedule.new
		new_recur.testtype 		= testtype
		new_recur.name 			= params[:testtitle]
		new_recur.brand 		= params[:brand]
		new_recur.brand 		= 'all' if(params[:brand].nil?)
		new_recur.grcid			= params[:campaign]
		new_recur.environment 	= params[:server]
		new_recur.realm 	= params[:realm]
		new_recur.driver 		= params[:browser]
		new_recur.driver 		= params[:driver] if params[:driver]
		new_recur.platform 		= params[:platform]
		new_recur.customurl 	= params[:custom_url] 
		new_recur.customoffer 	= params[:custom_offer]
		new_recur.email 		= params[:emailnotification]
		new_recur.email 		= params[:email] if params[:email]
		new_recur.pixel_suite	= params[:testsuite] if params[:testsuite]
		new_recur.weeklyday 	= params[:day] if(type == 'weekly')
		new_recur.dailyhour		= time.hour
		new_recur.dailyminute	= time.min
		new_recur.lastrundate 	= Date.yesterday.to_s
		new_recur.creationdate 	= Time.now.to_s		
		custom_settings = {}		
	    custom_settings['retries'] 				= params[:retries] if params[:retries]
        if params[:robottxtseocheck]
	    	custom_settings['robottxtseocheck'] 				= params[:robottxtseocheck]
	    else
	    	custom_settings['robottxtseocheck'] 				= "1"
	    end
	    if params[:sitemapxmlseocheck]
	    	custom_settings['sitemapxmlseocheck'] 				= params[:sitemapxmlseocheck]
	    else
	    	custom_settings['sitemapxmlseocheck'] 				= "1"
	    end
	    if params[:homepageseocheck]
	    	custom_settings['homepageseocheck'] 				= params[:homepageseocheck]
	    else
	    	custom_settings['homepageseocheck'] 				= "1"
	    end
	    if params[:saspageseocheck]
	    	custom_settings['saspageseocheck'] 				= params[:saspageseocheck]
	    else
	    	custom_settings['saspageseocheck'] 				= "1"
	    end  
	    if params[:cartpageseocheck]
	    	custom_settings['cartpageseocheck'] 				= params[:cartpageseocheck]
	    else
	    	custom_settings['cartpageseocheck'] 				= "1"
	    end
	    if params[:confirmationseocheck]
	    	custom_settings['confirmationseocheck'] 				= params[:confirmationseocheck]
	    else
	    	custom_settings['confirmationseocheck'] 				= "0"
	    end
	    new_recur.custom_settings = custom_settings # we will need to add params to this value.
		new_recur.active 		= 1
		new_recur.save!
		log_action('Create', current_user ? current_user.username : 'Anonymous', new_recur.id, 'RecurringSchedule')
	end

	##
	#
	def handle_recurring_schedule_failure(action, past_tense)
		begin
			yield
			flash[:success] = "Recurring Test Run #{past_tense}"
 		rescue => e
      flash[:danger] = "Failed to #{action} Test"
    end
	end

	def generate_vanity_test(params, user = 'automation')
	    test_urls = PixelTest.find(params[:testsuite]).test_urls

	    if(params[:test_url_target])
	      test_urls = []
	      params[:test_url_target].each do |key, value|
	        test_urls.push(TestUrl.find(key.to_i))
	      end
	    end

	    test_suite = PixelTest.find(params[:testsuite])
	    new_suite = TestSuites.new()
	    new_suite['Test Suite Name'] = test_suite.testname
	    new_suite['Environment'] = test_suite.environment.downcase
	    new_suite['Brand'] = 'all'
	    new_suite['scheduledate'] 				= params[:datetime] if(params[:datetime])
		new_suite['scheduledate'] 				= params[:scheduledate].gsub(/ -[\d]+/,'') if params[:scheduledate]
		new_suite['scheduleid'] 				= params[:scheduleid] if params[:scheduleid]
		
	    new_suite.TotalTests = test_urls.count
	    new_suite['Platform'] = params[:platform]
	    new_suite.SuiteType = 'vanity'
	    new_suite.DateTime = Time.now.strftime('%Y-%m-%d %H:%M:%S')
	    new_suite.email_random 					= params[:email_random]

	    new_suite['Ran By'] = 'Anonymous'
	  	begin
	      new_suite['Ran By'] = (user) if(user)
	  	rescue => e

	    end	
	    new_suite.Browser = 'Firefox'
	    new_suite.Browser =  params[:driver] if params[:driver]
	    new_suite.emailnotification = params[:email]
	    new_suite.save!

	    test_urls.each do |url|

	    	custom_settings = {}
	    	# custom_settings['multiple_pixel'] = params[:multiple_pixel] if params[:multiple_pixel]
	    	custom_settings['retries'] 				= params[:retries] if params[:retries]
	    	# custom_settings['status_code'] 		= params[:status_code] if params[:status_code]
	    	# custom_settings['nonexistant'] 		= params[:nonexistant] if params[:nonexistant]

	      mmtest = url.mmtest.to_s
	      mmtest = test_suite.mmtest.to_s if(test_suite.mmtest == "yes")
	      new_run = TestRun.new(url: gen_url( url.url.to_s, url.appendstring.to_s, (mmtest.to_s != "no")))
	      new_run['custom_settings'] = custom_settings
	      new_run.driverplatform = params[:platform]
	      new_run.platform = params[:platform]
	      
	      new_run.testtype = "vanity"
	      new_run['scheduledate'] 	=  Time.strptime(params[:datetime], "%m/%d/%Y %l:%M %p") if(params[:datetime])
				new_run['scheduledate'] 	= params[:scheduledate].gsub(/ -[\d]+/,'') if(params[:scheduledate])

	      new_run.isolated = 1 if params[:isolated]
	      

	      new_run.runby = 'Anonymous'
	      new_run.runby = (user) if(user)
	      new_run.test_suites_id = new_suite.id
	      new_run.status = "Not Started"
	      new_run.driver = 'firefox'
	      new_run.driver = params[:driver] if params[:driver]
	      new_run.datetime = Time.now.strftime('%Y-%m-%d %H:%M:%S')
	      new_run.save!

	      if(url.uci.to_s.empty? == false)
		      # generate validation for landing UCI
		      uci_landing = TestStep.new()
	        uci_landing.expected = url.uci
	        uci_landing.step_name = "Landing UCI"
	        uci_landing.test_run_id = new_run.id
	        uci_landing.save!

	        # generate validation for SAS UCI
	        uci_sas = TestStep.new()
	        uci_sas.expected = url.uci
	        uci_sas.step_name = "SAS UCI"
	        uci_sas.test_run_id = new_run.id
	        uci_sas.save!
	      end

	      if(url.campaign.to_s.empty? == false)
	      	# generate validation for offercode
	      	offer_step 							= TestStep.new()
	      	offer_step.expected 		= url.campaign
	      	offer_step.step_name 		= "Campaign"
	      	offer_step.test_run_id 	= new_run.id
	      	offer_step.save!
	      end

        if(url.offercode.to_s.empty? == false)
	        # generate validation for offercode
	        offer_step 				= TestStep.new()
	        offer_step.expected 	= url.offercode
	        offer_step.step_name 	= "Offercode"
	        offer_step.test_run_id 	= new_run.id
	        offer_step.save!
	      end
	    end
	    begin
	   		log_action('Run Vanity Test', current_user ? current_user.username : 'Scheduler', new_suite.id, 'TestSuite')
	   	rescue => e

	   	end
	   	return new_suite
	end

	def generate_uci_test(params, user = 'automation')
	    test_urls = PixelTest.find(params[:testsuite]).test_urls

	    if(params[:test_url_target])
	      test_urls = []
	      params[:test_url_target].each do |key, value|
	        test_urls.push(TestUrl.find(key.to_i))
	      end
	    end

	    test_suite = PixelTest.find(params[:testsuite])
	    new_suite = TestSuites.new()
	    new_suite['Test Suite Name'] = test_suite.testname
	    new_suite['Environment'] = test_suite.environment.downcase
	    new_suite['Brand'] = 'all'
	    new_suite['scheduledate'] 				= params[:datetime] if(params[:datetime])
		new_suite['scheduledate'] 				= params[:scheduledate].gsub(/ -[\d]+/,'') if params[:scheduledate]
		new_suite['scheduleid'] 				= params[:scheduleid] if params[:scheduleid]
	    new_suite.TotalTests = test_urls.count
	    new_suite['Platform'] = params[:platform]
	    new_suite.SuiteType = 'uci'
	    new_suite.DateTime = Time.now.strftime('%Y-%m-%d %H:%M:%S')
	    new_suite.email_random 					= params[:email_random]

	    new_suite['Ran By'] = 'Anonymous'
	  	begin
	      new_suite['Ran By'] = (user) if(user)
	  	rescue => e

	    end	
	    new_suite.Browser = 'Firefox'
	    new_suite.Browser =  params[:driver] if params[:driver]
	    new_suite.emailnotification = params[:email]
	    new_suite.save!

	    test_urls.each do |url|
	    	custom_settings = {}
	    	# custom_settings['multiple_pixel'] = params[:multiple_pixel] if params[:multiple_pixel]
	    	custom_settings['retries'] 				= params[:retries] if params[:retries]
	    	# custom_settings['status_code'] 		= params[:status_code] if params[:status_code]
	    	# custom_settings['nonexistant'] 		= params[:nonexistant] if params[:nonexistant]

	      mmtest = url.mmtest.to_s
	      mmtest = test_suite.mmtest.to_s if(test_suite.mmtest == "yes")
	      new_run = TestRun.new(url: gen_url( url.url.to_s, url.appendstring.to_s, (mmtest.to_s != "no")))
	      new_run['custom_settings'] = custom_settings
	      new_run.driverplatform = params[:platform]
	      new_run.platform = params[:platform]
	      
	      new_run.testtype = "uci"
	      new_run['scheduledate'] 	=  Time.strptime(params[:datetime], "%m/%d/%Y %l:%M %p") if(params[:datetime])
				new_run['scheduledate'] 	= params[:scheduledate].gsub(/ -[\d]+/,'') if(params[:scheduledate])

	      new_run.isolated = 1 if params[:isolated]
	      

	      new_run.runby = 'Anonymous'
	      new_run.runby = (user) if(user)
	      new_run.test_suites_id = new_suite.id
	      new_run.status = "Not Started"
	      new_run.driver = 'firefox'
	      new_run.driver = params[:driver] if params[:driver]
	      new_run.datetime = Time.now.strftime('%Y-%m-%d %H:%M:%S')
	      new_run.save!
	      
	      if(url.uci.to_s.empty? == false)
	    	# generate validation for landing UCI
	    	uci_landing 			= TestStep.new()
	        uci_landing.expected 	= url.uci
	        uci_landing.step_name 	= "Landing UCI"
	        uci_landing.test_run_id = new_run.id
	        uci_landing.save!

	        # generate validation for SAS UCI
	        uci_sas 			= TestStep.new()
	        uci_sas.expected 	= url.uci
	        uci_sas.step_name 	= "SAS UCI"
	        uci_sas.test_run_id = new_run.id
	        uci_sas.save!

	        # generate validation for SAS UCI
	        uci_cp 				= TestStep.new()
	        uci_cp.expected 	= url.uci
	        uci_cp.step_name 	= "Confirmation UCI"
	        uci_cp.test_run_id 	= new_run.id
	        uci_cp.save!
	      end

	      if(url.campaign.to_s.empty? == false)
	      	# generate validation for offercode
	      	offer_step 							= TestStep.new()
	      	offer_step.expected 		= url.campaign
	      	offer_step.step_name 		= "Campaign"
	      	offer_step.test_run_id 	= new_run.id
	      	offer_step.save!
	      end

        if(url.offercode.to_s.empty? == false)
	        # generate validation for offercode
	        offer_step 				= TestStep.new()
	        offer_step.expected 	= url.offercode
	        offer_step.step_name 	= "Offercode"
	        offer_step.test_run_id 	= new_run.id
	        offer_step.save!
	      end

        # generate validation for Confirmation #
        conf_num_step 				= TestStep.new()
        conf_num_step.expected 		= "Exists"
        conf_num_step.step_name 	= "Confirmation Number"
        conf_num_step.test_run_id 	= new_run.id
        conf_num_step.save!
	    end
	    begin
		    log_action('Run UCI Test', current_user ? current_user.username : 'Scheduler', new_suite.id, 'TestSuite')
		rescue => e
		end
		return new_suite
	end
	
	def generate_seo_test(params, user = 'automation')
	    test_urls = PixelTest.find(params[:testsuite]).test_urls

	    if(params[:test_url_target])
	      test_urls = []
	      params[:test_url_target].each do |key, value|
	        test_urls.push(TestUrl.find(key.to_i))
	      end
	    end

	    test_suite = PixelTest.find(params[:testsuite])
	    new_suite = TestSuites.new()
	    new_suite['Test Suite Name'] = test_suite.testname
	    new_suite['Environment'] = test_suite.environment.downcase
	    new_suite['Brand'] = 'all'
	    new_suite['scheduledate'] 				= params[:datetime] if(params[:datetime])
		new_suite['scheduledate'] 				= params[:scheduledate].gsub(/ -[\d]+/,'') if params[:scheduledate]
		new_suite['scheduleid'] 				= params[:scheduleid] if params[:scheduleid]
	    new_suite.TotalTests 					= test_urls.count
	    new_suite['Platform'] 					= params[:platform]
	    new_suite.SuiteType 					= 'seo'
	    new_suite.DateTime 						= Time.now.strftime('%Y-%m-%d %H:%M:%S')
	    new_suite.email_random 					= params[:email_random]

	    new_suite['Ran By'] = 'Anonymous'
	  	begin
	      new_suite['Ran By'] = (user) if(user)
	  	rescue => e

	    end	
	    new_suite.Browser = 'Firefox'
	    new_suite.Browser =  params[:driver] if params[:driver]
	    new_suite.emailnotification = params[:email]
	    new_suite.save!

	    test_urls.each do |url|
	    	custom_settings = {}
	    	
	    	custom_settings['retries'] 				= params[:retries] if params[:retries]
        custom_settings['robottxtseocheck'] 	= params[:robottxtseocheck] if params[:robottxtseocheck]
	    	custom_settings['sitemapxmlseocheck'] 		= params[:sitemapxmlseocheck] if params[:sitemapxmlseocheck]
	    	custom_settings['homepageseocheck'] 	= params[:homepageseocheck] if params[:homepageseocheck]
	    	custom_settings['saspageseocheck'] 		= params[:saspageseocheck] if params[:saspageseocheck]
	    	custom_settings['cartpageseocheck'] 		= params[:cartpageseocheck] if params[:cartpageseocheck]
	    	custom_settings['confirmationseocheck'] = params[:confirmationseocheck] if params[:confirmationseocheck]

	    	# custom_settings['is_core'] = url.is_core
		    #   mmtest = url.mmtest.to_s
		    #   mmtest = test_suite.mmtest.to_s if(test_suite.mmtest == "yes")
		      # custom_settings['mmtest'] = (mmtest.to_s != "no")
		      new_run = TestRun.new(url: gen_url( url.url.to_s, url.appendstring.to_s, false))
		      new_run['custom_settings'] = custom_settings
		      new_run.driverplatform = params[:platform]
		      new_run.platform = params[:platform]
		      # new_run.realm = url.realm
		      
		      new_run.testtype = "seo"
		      new_run['scheduledate'] 	=  Time.strptime(params[:datetime], "%m/%d/%Y %l:%M %p") if(params[:datetime])
			  	new_run['scheduledate'] 	= params[:scheduledate].gsub(/ -[\d]+/,'') if(params[:scheduledate])

		      new_run.isolated = 1 if params[:isolated]
		      

		      new_run.runby = 'Anonymous'
		      new_run.runby = (user) if(user)
		      new_run.test_suites_id = new_suite.id
		      new_run.status = "Not Started"
		      new_run.driver = 'firefox'
		      new_run.driver = params[:driver] if params[:driver]
		      new_run.datetime = Time.now.strftime('%Y-%m-%d %H:%M:%S')
		      new_run.save!

		      # SEO File Checks
	      	if(custom_settings["robottxtseocheck"].nil? == false)
	      		# generate expected file
	      		url_host = new_run.url.match(/\/*\/*([^\/]+)/).captures().first
	      		robots_txt_obj = SeoFile.where('filename = ?', "robots.txt").where("domain like ?", url_host).first()
	      		begin
			        File.open(Rails.root.join('public', "debug/seo/#{new_run.id}_expected_robots.txt"), "w") { |file|  
			          file.write robots_txt_obj.valid_content.gsub("\r","")
			          file.close
			        } 
			      rescue => e
			        e.display
			      end
		      	# generate validation for SEO
		      	seo_redirect_type 							= TestStep.new()
		      	seo_redirect_type.expected 			= "<a href='/debug/seo/#{new_run.id}_expected_robots.txt' target='_blank'>Link to expected robots.txt</a>"
		      	seo_redirect_type.step_name 		= "robots.txt"
		      	seo_redirect_type.test_run_id 	= new_run.id
		      	seo_redirect_type.save!
		      end
		      url_host = new_run.url.match(/\/*\/*([^\/]+)/).captures().first
	      	sitemap_xml_objs = SeoFile.where('filename = ?', "sitemap.xml").where("domain like ?", url_host)
	      		
	      	sitemap_xml_objs.each do |file_obj|
			      if(custom_settings["sitemapxmlseocheck"].nil? == false)
		      		
			      	# generate validation for SEO
			      	seo_redirect_type 							= TestStep.new()
			      	seo_redirect_type.step_name 		= file_obj.targeturl.split(//).last(50).join()
			      	seo_redirect_type.test_run_id 	= new_run.id
			      	seo_redirect_type.save!
			      	seo_redirect_type.expected 			= "<a href='/debug/seo/#{new_run.id}_#{seo_redirect_type.id}_expected_sitemap.xml' target='_blank'>Link to expected sitemap.xml</a>"
			      	seo_redirect_type.save!
			      	# generate expected file
		      		begin
				        File.open(Rails.root.join('public', "debug/seo/#{new_run.id}_#{seo_redirect_type.id}_expected_sitemap.xml"), "w") { |file|  
				          file.write file_obj.valid_content.gsub("\r","")
				          file.close
				        } 
				      rescue => e
				        e.display
				      end
			      end

			    end

	      	# generate validation for SEO
	      	seo_redirect_code 					= TestStep.new()
	      	seo_redirect_code.expected 			= "Correct"
	      	seo_redirect_code.step_name 		= "Redirect Status Code"
	      	seo_redirect_code.test_run_id 		= new_run.id
	      	seo_redirect_code.save!




		      if(custom_settings["homepageseocheck"].nil? == false)
		      	# generate validation for SEO
		      	seo_redirect_type 					= TestStep.new()
		      	seo_redirect_type.expected 			= "Correct"
		      	seo_redirect_type.step_name 		= "Homepage SEO Canonical Tag"
		      	seo_redirect_type.test_run_id 		= new_run.id
		      	seo_redirect_type.save!
		      end

		      if(custom_settings["homepageseocheck"].nil? == false)
		      	# generate validation for SEO
		      	seo_redirect_type 					= TestStep.new()
		      	seo_redirect_type.expected 			= "Correct"
		      	seo_redirect_type.step_name 		= "Homepage SEO Robots Tag"
		      	seo_redirect_type.test_run_id 		= new_run.id
		      	seo_redirect_type.save!
		      end

		      if(custom_settings["saspageseocheck"].nil? == false)
		      	# generate validation for SEO
		      	seo_redirect_type 					= TestStep.new()
		      	seo_redirect_type.expected 			= "Correct"
		      	seo_redirect_type.step_name 		= "SAS SEO Canonical Tag"
		      	seo_redirect_type.test_run_id 		= new_run.id
		      	seo_redirect_type.save!
		      end

		      if(custom_settings["saspageseocheck"].nil? == false)
		      	# generate validation for SEO
		      	seo_redirect_type 					= TestStep.new()
		      	seo_redirect_type.expected 			= "Correct"
		      	seo_redirect_type.step_name 		= "SAS SEO Robots Tag"
		      	seo_redirect_type.test_run_id 		= new_run.id
		      	seo_redirect_type.save!
		      end

		      if(custom_settings["cartpageseocheck"].nil? == false)
		      	# generate validation for SEO
		      	seo_redirect_type 					= TestStep.new()
		      	seo_redirect_type.expected 			= "Correct"
		      	seo_redirect_type.step_name 		= "Cart SEO Canonical Tag"
		      	seo_redirect_type.test_run_id 		= new_run.id
		      	seo_redirect_type.save!
		      end

		      if(custom_settings["cartpageseocheck"].nil? == false)
		      	# generate validation for SEO
		      	seo_redirect_type 					= TestStep.new()
		      	seo_redirect_type.expected 			= "Correct"
		      	seo_redirect_type.step_name 		= "Cart SEO Robots Tag"
		      	seo_redirect_type.test_run_id 		= new_run.id
		      	seo_redirect_type.save!
		      end

		      if(custom_settings["confirmationseocheck"].nil? == false)
		      	# generate validation for SEO
		      	seo_redirect_type 					= TestStep.new()
		      	seo_redirect_type.expected 			= "Correct"
		      	seo_redirect_type.step_name 		= "Confirmation SEO Canonical Tag"
		      	seo_redirect_type.test_run_id 		= new_run.id
		      	seo_redirect_type.save!
		      end

		      if(custom_settings["confirmationseocheck"].nil? == false)
		      	# generate validation for SEO
		      	seo_redirect_type 					= TestStep.new()
		      	seo_redirect_type.expected 			= "Correct"
		      	seo_redirect_type.step_name 		= "Confirmation SEO Robots Tag"
		      	seo_redirect_type.test_run_id 		= new_run.id
		      	seo_redirect_type.save!

		      	# generate validation for Confirmation #
		        conf_num_step 				= TestStep.new()
		        conf_num_step.expected 		= "Exists"
		        conf_num_step.step_name 	= "Confirmation Number"
		        conf_num_step.test_run_id 	= new_run.id
		        conf_num_step.save!
		      end

	     #    if(url.offercode.to_s.empty? == false)
		    #     # generate validation for offercode
		    #     offer_step 				= TestStep.new()
		    #     offer_step.expected 	= url.offercode
		    #     offer_step.step_name 	= "Offercode"
		    #     offer_step.test_run_id 	= new_run.id
		    #     offer_step.save!
		    # end

	    end
	    begin
		    log_action('Run SEO Test', current_user ? current_user.username : 'Scheduler', new_suite.id, 'TestSuite')
		rescue => e
		end
		return new_suite
	end



	##
	# TODO - DOCUMENT NEW METHOD
	def get_brands(params)
		# pull the brand from the parameters
		brand = params[:brand]
		if(brand == 'all')
			brands = []
			brand_objs = Brands.all()
			brand_objs.each do |obj|
				if params[:brand_subset]
					brands.push(obj['Brandname']) if(params[:brand_subset].include?(obj['Brandname']))
				else
					brands.push(obj['Brandname'])
				end
			end
		else
			brands = [brand]
		end

		return brands
	end
	##
	# TODO - DOCUMENT NEW METHOD
	def create_test(params, type)
    puts "creating buyflow test"
    puts "parameters"
    puts params
    puts "type"
    puts type
		campaign_original = params[:campaign]
		require_relative Rails.root.join("lib/grotto/import.rb")
		
		# Rails.logger.info "getting brands"
		brands = get_brands(params)
		realms = []
		realms.push(params[:realm]) if params[:realm] != 'all'
		realms = ['realm1', 'realm2', 'realm3'] if params[:realm] == 'all'

		params[:datetime] = DateTime.strptime(params[:datetime], '%m/%d/%Y %H:%M %p') if(params[:datetime])
		
		test_total = 0

		brands_missing = []

		new_suite = create_suite(params, type)
		# Rails.logger.info "looping through brands"
		realms.each do |realm|
			params[:realm] = realm
			
			brands.each do |brand|
				params[:campaign] = campaign_original
				campaign = Campaign.where('grcid' => params[:campaign], 'Brand' => brand, 'environment' => params[:server], 'experience' => params[:platform], 'realm' => params[:realm])# , 'is_test_panel' => true)
				campaign = campaign.first()
				campaigns = nil
				
				if(!campaign.nil?)
					if(campaign['grcid'] == "core-campaign" && campaign["is_test_panel"])										
						campaigns = Campaign.where('Brand' => brand, 'environment' => params[:server], 'experience' => params[:platform], 'realm' => params[:realm], 'is_test_panel' => true)
					else
						campaigns = [campaign]
					end
					#if(!campaign.empty? && !campaign.include?(nil))
					campaigns.each do |campaign|
						params['campaign'] = campaign['grcid']
						if(type == "Offercode")

							#offers = campaign.offerdata.where('isvitamin' => 0)
							if params[:custom_offer].empty?
								offers = campaign.offerdata.where('isvitamin' => 0, 'OfferCode' => campaign.default_offercode)
							else	
								offers = campaign.offerdata.where('isvitamin' => 0)
							end

							if(params[:custom_offer].include?(';'))
								offers= []
								custom_offer = params[:custom_offer].split(';')
								custom_offer.each do |offer|
									offers.push({"OfferCode" => offer.strip})
								end
							else
								if(params[:custom_offer].empty? == false)
									offers = [{"OfferCode" => params[:custom_offer]}]
								end
							end
						else
							offers= []
							# if(params[:custom_offer].include?(';'))
              #   custom_offer = params[:custom_offer].split(';')
              #   custom_offer.each do |offer|
              #     offers.push({"OfferCode" => offer.strip})
              #   end
              # else
              #   offers = [{"OfferCode" => params[:custom_offer]}]
              # end
              puts "cuuuuuuuustom oooooooffer"
              puts params[:custom_offer]
              if(params[:custom_offer].include?(';'))
                if ((brand == 'Marajo') || (brand == 'smileactives'))
                  offers = [{"OfferCode" => params[:custom_offer]}]
                else
                  custom_offer = params[:custom_offer].split(';')
                  custom_offer.each do |offer|
                    offers.push({"OfferCode" => offer.strip})
                  end
                end
              else
                offers = [{"OfferCode" => params[:custom_offer]}]
              end
            end

						# Rails.logger.info "looping through offerdata"

						offers.each do |offer|
							# Rails.logger.info "creating testrun for #{offer['OfferCode']}"
							new_run = create_testrun(brand, offer, type, new_suite, params)
							
							# Rails.logger.info "check for campaign existance"
							if(GRDatabase.get_campaign_data(new_run['Brand'], new_run['expectedcampaign'], new_run['Env'], new_run['DriverPlatform'], new_run['realm']).entries[0])
								new_run.save!
								test_total += 1
							else
								brands_missing.push(new_run['Brand'])
							end
						end
					end
				end
			end
		end

		

		# Rails.logger.info "check for test length"
		if(test_total == 0)
			new_suite.destroy!
			raise "No Offer Codes found for this suite"
		end 

		

		new_suite['TotalTests'] = test_total

		new_suite['Pass'] = 0

		new_suite.save!

		# Rails.logger.info "update suite completion"
		begin
			log_action('Run Buyflow Test', current_user ? current_user.username : 'Scheduler', new_suite.id, 'TestSuite')
		rescue => e

		end
		return new_suite
	end

	##
	# TODO - DOCUMENT NEW METHOD
	# TODO - parameter override for ran by using jenkins
	def create_suite(params, type)
		new_suite = TestSuites.new()
		new_suite['Ran By'] 			= "Automation"
		# begin
		# 	new_suite['Ran By']				= current_user.username if(current_user)
		# rescue => e
		# 	puts "ERR: #{e.message}"
		# end
		new_suite['Test Suite Name']			= "#{params[:brand]} - #{params[:campaign]} - Buyflow"
		new_suite['DateTime'] 					= Time.now.strftime('%Y-%m-%d %H:%M:%S')
		new_suite['Brand'] 						= params[:brand]
		new_suite['Campaign'] 					= params[:campaign]
		new_suite['Environment'] 				= params[:server]
		new_suite['realm'] 						= params[:realm]
		new_suite['Browser'] 					= params[:browser]
		new_suite['Platform'] 					= params[:platform]
		new_suite['URL'] 						= params[:custom_url]
		new_suite['offercode'] 					= params[:custom_offer]
		new_suite['emailnotification'] 			= params[:emailnotification]
		new_suite['scheduledate'] 				= params[:datetime] if(params[:datetime])
		new_suite['scheduledate'] 				= params[:scheduledate].gsub(/ -[\d]+/,'') if params[:scheduledate]
		new_suite.email_random 					= params[:email_random]
		new_suite['scheduleid'] 				= params[:scheduleid] if params[:scheduleid]
		new_suite['SuiteType'] 					= type
		new_suite.is_upsell 					= params[:is_upsell]
		puts "saving new suite"
		new_suite.save!
		return new_suite
	end
end
