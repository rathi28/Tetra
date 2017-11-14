require 'open-uri'
class DashboardController < ApplicationController

	# setup default action for path
	def index
	  	# set the header message
	  	@headertext = "Dashboard"

	  	# session[:current_user_id] = 123

	  	# get data for buyflow results component
	  	@buyflow 	= TestSuites.where('SuiteType' => 'Buyflow').limit(5).order("id desc")

		# get data for offercode results component
		@offercode 	= TestSuites.where('SuiteType' => 'Offercode').limit(5).order("id desc")

		# get data for Pixels results component
		@pixels 	= TestSuites.where('SuiteType' => 'pixels').limit(5).order("id desc")
		# get data for Vanity results component
		@vanity 	= TestSuites.where('SuiteType' => 'Vanity').limit(5).order("id desc")
		# get data for UCI results component
		@ucitests 	= TestSuites.where('SuiteType' => 'UCI').limit(5).order("id desc")
		# get data for SEO results component
		@seo 	= TestSuites.where('SuiteType' => 'seo').limit(5).order("id desc")
	end
	
	##
	# Dashboard action for admins panel
	def admin_dash
		# Any admin dashboard data should be collected here.
		admin_only do
			require_relative Rails.root.join("lib/grotto/browser/grid_utilities.rb")
			# collect all the worker tasks
			@worker_lanes = Delayed_Job.all().where(:failed_at => nil)
			@grid_hub = Grid_Processes.where(:role => 'hub').first
			@grid_nodes = Grid_Processes.where.not(:role => 'hub').where.not(:role => 'proxy')
			@hub_status = GridUtilities.is_hub_online?(host: @grid_hub.ip, port:@grid_hub.port)
			@grid_nodes_status = {}
			@grid_nodes.each do |node|
				begin
					@grid_nodes_status[node.id] = open("http://#{node.ip}:#{node.port}/wd/hub/status").status[0] == "200" ? true : false
				rescue
					@grid_nodes_status[node.id] = false
				end				
			end
		end
	end
end