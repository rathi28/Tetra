require 'open-uri'
require 'json'
require 'pry'
require 'nokogiri'
require 'timeout'

##
# This is a class for combining the public APIs for Selenium Grid along with the Grid Console to form an API for checking the status of the Grid and its Nodes.
class GridUtilities
	@testsession_endpoint_format = "http://%s:%s/grid/api/testsession?session=%s"
	@hub_endpoint_format 	= "http://%s:%s/grid/api/hub"
	@grid_endpoint_format 	= "http://%s:%s/grid/console"
	@node_endpoint_format 	= "http://%s:%s/grid"

	##
	# Returns whether the Hub is currently online using the Hub's public API
	# @param [String] host The Host Address for the Hub you wish to check
	# @param [String] port The Port number for the Hub you wish to check 
	# @return [boolean] boolean answer to the question 'is the hub online?'
	def self.is_hub_online?(host: '192.168.1.254', port: '4444')
		return hub_status(host: host, port: port)['success']
	end

	##
	# Accesses the hub's API and returns the status json, parsing it into a ruby object and then returning that.
	# @param [String] host The Host Address for the Hub you wish to check
	# @param [String] port The Port number for the Hub you wish to check 
	# @return [Hash] JSON response of status.
	def self.hub_status(host: '192.168.1.254', port: '4444')
		response_as_string_io = nil
		fail_response = {'success' => false}
		begin
			Timeout::timeout(1) {
				# firing off API call to hub for response
				response_as_string_io 	= open(@hub_endpoint_format % [host, port])
			}

		rescue Errno::ETIMEDOUT => e
			return fail_response
		rescue Timeout::Error => e
			return fail_response
		rescue => e
			return fail_response
		end
		# Parses response stirng
		response_body_as_string = response_as_string_io.read
		response_body_as_hash 	= JSON.parse(response_body_as_string)
		return response_body_as_hash
	end

	##
	# Possible Deprecated - needs rewriting for sure
			# better to use 
			# @grid_nodes.each do |node|
			#	@grid_nodes_status[node.id] = open("http://#{node.ip}:#{node.port}/wd/hub/status").status[0]
			# end
	# Returns whether the Node is currently online.
	# @param [String] host The Host Address for the Node you wish to check
	# @param [String] port The Port number for the Node you wish to check 
	# @return [Boolean] Answers the statement 'Is the Node online?'
	def self.is_node_online?(host: '192.168.1.254', port: '5555')
		begin
			# Locators for host and port on the console page
			node_host_css = 'div.content > div[type="config"] p:nth(17)'
			node_port_css = 'div.content > div[type="config"] p:nth(15)'
			# regular expression for the host address
			node_host_regex = 'host:([^<]+)'
			# regular expression for the port number
			node_port_regex = 'port:([^<]+)'

			# initialize online_nodes has as empty hash
			online_nodes = {}

			# get the page object for the console
			page = get_console_page()

			# get the page element for the host address
			node_host_elements = page.css(node_host_css)

			# get the page element for the port number
			node_port_elements = page.css(node_port_css)

			# iterate through the host elements
			node_host_elements.each_with_index do |node_host_element, index|
				# pull the host address from element
				node_host = node_host_element.to_s.match(node_host_regex).captures.first
				# add a key for this host address along with an associated array
				online_nodes[node_host] = [] if(online_nodes[node_host].nil?)
				# pull the port number from the port number element for this node
				node_port = node_port_elements[index].to_s.match(node_port_regex).captures.first
				# add the port number for this node to the list of ports for this host
				online_nodes[node_host].push(node_port)
			end
			#Rails.logger.info online_nodes.to_s

			# return true if host/port combination exists on the grid currently
			return true if(online_nodes[host].include?(port))
		rescue => e
			#Rails.logger.info "failed to find node"
		end
		return false
	end

	def self.get_session_ip(host: '192.168.1.254', port: '4444', session: session)
		puts "getting session ip"
		begin
			# pull the selenium driver from the capybara browser
			selenium_driver = session.driver
			puts "selenium driver"
			puts selenium_driver
			# pull the browser details from the driver
			remote_browser = selenium_driver.browser
			puts "remote_browser"
			puts remote_browser
			# Get the session currently in use
			session_id = remote_browser.session_id
			puts "session_id"
			puts session_id
			api_call_url_string = @testsession_endpoint_format % [host, port, session_id]
			response = open(api_call_url_string)
			rawdata = response.read()
			session_data = JSON.parse(rawdata)
			if session_data['success']
				return session_data['proxyId']
			else
				return nil
			end
		rescue => e
			return nil
		end
	end

	##
	# The method scrapes the Grid Console page and returns whether a browser is available to test.
	# @param [String] driver_name The string representation of the driver used by BrowserFactory
	# @return [Boolean] whether a browser is available
	def self.browser_available(host: '192.168.1.254', port: '4444', driver_name: 'chrome')
		# get current browsers available for testing
		browser_count = get_browsers(host: host, port: port)

		case driver_name
		# Driver for chrome on selenium grid
		when 'grid-chrome'
			count = browser_count['chrome']
			if(count == 0)
				return false
			else
				return count
			end
		# Driver for firefox on selenium grid
		when 'grid-firefox'
			count = browser_count['firefox']
			if(count == 0)
				return false
			else
				return count
			end
		# Driver for ie on selenium grid
		when 'grid-ie'
			count = browser_count['internet explorer']
			if(count == 0)
				return false
			else
				return count
			end
		else
			return true
		end
	end

	##
	# Converts the page content pulled via Open-URI into a Nokogiri Page Object that can been queried like a capybara webpage
	# @param [String] host The Host Address for the Hub you wish to check
	# @param [String] port The Port number for the Hub you wish to check 
	# @return [Nokogiri::HTML] Console Page returned from Grid Hub
	def self.get_console_page(host: '192.168.1.254', port: '4444')
		begin
			# firing off API call to hub for response
			# send HTTP request to console page
			response_as_string_io 	= open(@grid_endpoint_format % [host, port])
			# Parses response stirng
			response_body_as_string = response_as_string_io.read
			# Convert the grid console into a query-able Nokogiri object
			page = Nokogiri::HTML(response_body_as_string)
			# return the Nokogiri page object
			return page
		rescue Errno::ETIMEDOUT => e
			# if the HTTP response times out
			return false
		rescue => e
			# put the error into the log
			Rails.logger.info e.message
			# Rails.logger.info the backtrace into the log
			Rails.logger.info e.backtrace if e.backtrace
		end
	end

	##
	# This method pulls out the icons on the grid console for each node and totals up the available browsers using the metadata stored in each icon's tag.
	# @param [String] host The Host Address for the Hub you wish to check
	# @param [String] port The Port number for the Hub you wish to check 
	# @return [Hash] Hash of the totals for each browser
	def self.get_browsers(host: '192.168.1.254', port: '4444')
		# String locators
		browser_icon_css = 'div[type="browsers"] > p + p.protocol:nth(1) ~ p > img[title]'
		browser_name_regex = 'browserName=([^,]+)'

		# get the Nokogiri format object for the console page
		page = get_console_page(host: host, port: port)

		# Query the page for the CSS matching a browser icon for an up browser
		browsers = page.css(browser_icon_css)

		# create an empty hash for all the browsers available
		browser_count = {}

		# iterate through browser icons to pull out the data stored in the title field
		browsers.each do |browser|

			# if it is a match to an available browser
			if(browser.to_s.match(browser_name_regex))

				# pull out the browsers name
				browserName = browser.to_s.match(browser_name_regex).captures.first

				# set that browser key to zero if first instance of it in list
				browser_count[browserName] = 0 if browser_count[browserName].nil?

				# add one to its count for this icon
				browser_count[browserName] += 1

			end
		end

		# return hash of all found browser counts
		return browser_count
	end
end