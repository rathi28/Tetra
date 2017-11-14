class TestsuitesController < ApplicationController
	include TestsuitesHelper
	# get data for the default path view and filter
	
	def index
		@debug_vars = []
	    if(current_user)
	      @default_email = current_user.email if(current_user.username)
	    end 
		@headertext = "#{params[:suitetype]} Test Suites"
		@suites = TestSuites.where('scheduledate < ? OR scheduledate IS NULL', Time.now.to_s)
		@browsers = Browsertypes.where(:active => "1")
	    @brands = Brands.all()
	    @testrun = Testrun.new()
	    
	    
		@type = params[:suitetype]
		filtering_params(params).each do |key, value|
			@suites = @suites.public_send(key, value) if value.present?
		end
		@suites = @suites.paginate(:page => params[:page], :per_page => 15).order('id DESC')
		
		@debug_vars.push @default_email
	    @debug_vars.push @suites
	    @debug_vars.push @browsers
	    @debug_vars.push @brands
	    @debug_vars.push @testrun
	    @debug_vars.push @type
	    @debug_vars.push params

	    if(params[:formats] == 'json')

	    end
	end

	def pause
		begin
			if(current_user.admin == "yes")
				@suite = TestSuites.find(params[:id])
				@suite.test_runs.each do |run|
					run.status = "Paused" if run.status != "Complete"
					run.save!
				end
				@suite.testruns.each do |run|
					run.status = "Paused" if run.status != "Complete"
					run.save!
				end
				@suite["Status"] = "Paused"
				@suite.save!
				flash[:success] = "Paused Test Suite Successfully"
				log_action('Pause', current_user ? current_user.username : 'Anonymous', params[:id], 'TestSuite')
				redirect_to action: "index", suitetype: params['type']
			end
		rescue => e
			flash[:danger] = "Failed to pause Suite - #{e.message}"
			redirect_to action: "index", suitetype: params['type']
		end
	end

	def resume
		begin
			if(current_user.admin == "yes")
				@suite = TestSuites.find(params[:id])
				@suite.test_runs.each do |run|
					run.status = "Not Started" if run.status != "Complete"
					run.save!
				end
				@suite.testruns.each do |run|
					run.status = "Not Started" if run.status != "Complete"
					run.save!
				end
				@suite["Status"] = "Not Started"
				@suite.save!
				flash[:success] = "Resumed Test Suite Successfully"
				log_action('Resume', current_user ? current_user.username : 'Anonymous', params[:id], 'TestSuite')
				redirect_to action: "index", suitetype: params['type']
			end
		rescue => e
			flash[:danger] = "Failed to resume Suite - #{e.message}"
			redirect_to action: "index", suitetype: params['type']
		end
	end

	#download test_suite data to an excel format file
	def download
		@testruns = Testrun.where(:test_suites_id => params[:id])
		@suite = TestSuites.find(params[:id])
		respond_to do |format| 
			format.xlsx {render xlsx: 'download', filename: "testsuite-#{params[:id]}.xlsx"}
		end
	end

	# create a new buyflow test based on parameters selected
	def buyflow_create
		
		if(params['scheduletype'].nil?)
			params['scheduletype'] = 'one-time'
		end

		case params['scheduletype'] 
		when "weekly"
			schedule_create('Buyflow', 'weekly', params)
			redirect_to controller: 'schedule', action: "index"
		when "daily"
			schedule_create('Buyflow', 'daily', params)
			redirect_to controller: 'schedule', action: "index"
		else
			# load the test scripts
			require_relative Rails.root.join("lib/grotto/import.rb")
			begin
				# Calls a Test Suites Helper Method
				create_test(params, 'Buyflow')
				redirect_to action: "index", suitetype: "buyflow"
			rescue => e
				flash[:danger] = "Failed to create Suite run: #{e.message}"				
				log_error_to_database(e)
				redirect_to action: "index", suitetype: "buyflow"
			end
		end
	end

	# create a new offercode test based on parameters selected
	def offercode_create
		if(params['scheduletype'].nil?)
			params['scheduletype'] = 'one-time'
		end

		case params['scheduletype']
		when "weekly"
			schedule_create('OfferCode', 'weekly', params)
			redirect_to controller: 'schedule', action: "index"
		when "daily"
			schedule_create('OfferCode', 'daily', params)
			redirect_to controller: 'schedule', action: "index"
		else
			begin
				# Calls a Test Suites Helper Methodww
				create_test(params, 'Offercode')

				redirect_to action: "index", suitetype: "offercode"
			rescue => e
				flash[:danger] = "Failed to create Suite run: #{e.message}"
				redirect_to action: "index", suitetype: "offercode"
			end
		end
	end

	# admin only delete method
	def destroy
		begin
			if(current_user.admin == "yes")
				suite = TestSuites.find(params[:id])
				suite.destroy!
				flash[:success] = "Removed Test Suite Successfully"
				log_action('Delete', current_user ? current_user.username : 'Anonymous', params[:id], 'TestSuite')
				redirect_to action: "index", suitetype: params['type']
			end
		rescue => e
			flash[:danger] = "Failed to delete Suite - #{e.message}"
			redirect_to action: "index", suitetype: params['type']
		end
	end

	# TestSuite View page
	def show
		begin
			@headertext = "Test Suite"
			@testruns = Testrun.where(:test_suites_id => params[:id])
			@test_runs = TestRun.where(:test_suites_id => params[:id])
			@total = @test_runs.count + @testruns.count
			@passed = @test_runs.where(result: 1).size + @testruns.where(result: 'pass').count
			@suite = TestSuites.find(params[:id])
			@debug_vars = [@passed, @total]
		rescue ActiveRecord::RecordNotFound => e
			flash[:danger] = "Could not find Test Suite with id: #{params[:id]}"
			redirect_to controller: "dashboard", action: "index"
		end
	end

	private

	# Testsuites filtering limiter
	def filtering_params(params)
		params.slice(:suitetype, :status)
	end
end