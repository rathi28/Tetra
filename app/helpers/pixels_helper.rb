require 'uri'
require 'cgi'

module PixelsHelper

  ##
  # workaround for non-encoding needs

  def hash_to_querystring(params_hash)
    query_string = []
    params_hash.each do |param_key, param_val|
      key = param_key
      value = ""
      begin
        value = param_val.to_s
      rescue => e

      end
      begin
        value = param_val.join
      rescue => e

      end
      string = [key, value].join('=')
      query_string.push(string)
    end

    return query_string.join('&')
  end

	##
	# Returns the url needed with its appending string merged in and optional test override
	# @param [String] url URL string for test
	# @param [String] appended_val Appending string with values
	# @param [Boolean] test MMcore test value needed?
	# @return [String] URL requested
	def gen_url(url, appended_val, test)

		if(!url.include? 'http')
  		url = "http://" + url
      ht_flag = "T" #Added to check if there is an http added automatically to a vanity/pixel url
		end

		# Generate the URI Objects
		url_uri = URI.parse(URI.encode(url.to_s.strip))
		append_uri = URI.parse(URI.encode(appended_val.to_s.strip.gsub(/^(&)/,'?')))

		url_query = url_uri.query
		append_query = append_uri.query
    

		# Get the parameters from each
		url_parameters = CGI.parse(url_query) if(url_query)
		append_parameters = CGI.parse(append_query) if(append_query)

		# merge the parameters
		parameters = {}
		parameters.merge!(url_parameters) if(url_parameters)
		parameters.merge!(append_parameters) if(append_parameters)

		# add test value if needed
		if(test)
			parameters.merge!({"mmcore.gm" => ["2"]})
		end

		# change hash to string format
		query_string =  hash_to_querystring(parameters)


		# clean out spare '/' marks
		path_url = url_uri.path
		path_append = append_uri.path
    
		# combine everything back into URI
		path_url = '' if(path_url == '/')
		path_append = '' if(path_append == '/')
    
		#url_uri.query = query_string 
    
		combine_path = path_url + path_append
		combine_path = '/' if combine_path[0] != '/'

    url_uri.path = combine_path
    url_uri.query = nil
    final_url = url_uri.to_s
		final_url = [url_uri.to_s, query_string].join('?') if(!query_string.empty?)
		# return the URI as string
    # Adding to remove an extra http added to the vanity url, linked to 41, here from 88-93
    if (ht_flag != 'T')
      return final_url.to_s.gsub('%7C','|').gsub('%23','#').gsub('%25','%')      
    else
      return final_url.to_s.gsub('%7C','|').gsub('%23','#').gsub('%25','%').gsub('http://','')
    end
    #return final_url.to_s.gsub('%7C','|').gsub('%23','#').gsub('%25','%')
	end

	def generate_pixel_test(params, user = 'automation', single_url = nil)
    test_urls = PixelTest.find(params[:testsuite]).test_urls

    if(params[:test_url_target])
      test_urls = []
      params[:test_url_target].each do |key, value|
        test_urls.push(TestUrl.find(key.to_i))
      end
    end

    accepted_pixels = []
    if(params[:pixel])
      params[:pixel].each do |key, value|
        accepted_pixels.push(PixelData.find(key).pixel_handle)
      end
    end

    test_suite = PixelTest.find(params[:testsuite])
    new_suite = TestSuites.new()
    new_suite['Test Suite Name'] = test_suite.testname
    new_suite['Environment'] = test_suite.environment.downcase
    new_suite['Brand'] = 'all'
    new_suite.TotalTests = test_urls.count
    new_suite['Platform'] = params[:platform]
    new_suite['scheduledate']         = params[:datetime] if(params[:datetime])
    new_suite['scheduledate']         = params[:scheduledate].gsub(/ -[\d]+/,'') if params[:scheduledate]
    new_suite['scheduleid']         = params[:scheduleid] if params[:scheduleid]
    new_suite.SuiteType = 'pixels'
    new_suite.DateTime = Time.now.strftime('%Y-%m-%d %H:%M:%S')

    new_suite['Ran By'] = 'Anonymous'
  	begin
      new_suite['Ran By'] = (user) if(user)
  	rescue => e

    end	
    new_suite.Browser = 'Firefox'
    new_suite.Browser =  params[:driver] if params[:driver]
    new_suite.emailnotification = params[:email]
    new_suite.email_random      = params[:email_random]
    new_suite.save!

    test_urls.each do |url|
    	custom_settings = {}
    	custom_settings['multiple_pixel'] = params[:multiple_pixel] if params[:multiple_pixel]
    	custom_settings['retries'] 				= params[:retries] if params[:retries]
    	custom_settings['status_code'] 		= params[:status_code] if params[:status_code]
    	custom_settings['nonexistant'] 		= params[:nonexistant] if params[:nonexistant]

      mmtest = url.mmtest.to_s
      mmtest = test_suite.mmtest.to_s if(test_suite.mmtest == "yes")
      new_run = TestRun.new(url: gen_url( url.url.to_s, url.appendstring.to_s, (mmtest.to_s != "no")))
      new_run['custom_settings'] = custom_settings
      new_run.testtype = url.page_type
      new_run.driverplatform = params[:platform]
      new_run.platform = params[:platform]
      
      new_run.testtype = "pixel_content_single"
      new_run.testtype = "pixel_confirmation" if(url.page_type.downcase.include?('confirm'))
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

      if params[:nonexistant]
        test_pixels = PixelData.where(test_url_id: url.id)
      else
        test_pixels = PixelData.where(test_url_id: url.id, expected_state: 1)
      end

      test_pixels.each do |pixel|
        if(accepted_pixels.include?(pixel.pixel_handle) || accepted_pixels.empty?)
          new_step = TestStep.new()
          new_step.expected = pixel.expected_state
          new_step.step_name = pixel.pixel_handle
          new_step.test_run_id = new_run.id
          new_step.save!
        end
      end
    end
    return new_suite
  end
end
