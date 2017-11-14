class TestRunController < ApplicationController
  include PixelsHelper
  include TestsuitesHelper

  def create_run
    logged_in_only do
      @suitetype = params[:suitetype].nil? ? 'pixels' : params[:suitetype]
      if(params['scheduletype'].nil?)
        params['scheduletype'] = 'one-time'
      end

      case params['scheduletype']
      when "weekly"
        schedule_create(@suitetype, 'weekly', params)
        redirect_to controller: 'schedule', action: "index"

      when "daily"
        schedule_create(@suitetype, 'daily', params)
        redirect_to controller: 'schedule', action: "index"

      else
        begin
          if(params["test_url_target"] == nil)
            raise "No URLS Selected for testrun"
          end

          case @suitetype

          when 'pixels'
            generate_pixel_test(params, current_user.username)

          when 'Vanity'
            generate_vanity_test(params, current_user.username)

          when 'UCI'
            generate_uci_test(params, current_user.username)
          when 'seo'
            generate_seo_test(params, current_user.username)
          end
          redirect_to '/testsuites/' + (@suitetype ? @suitetype.downcase : '')
        rescue => e
          flash[:danger] = "Failed to create Suite run: #{e.message}"
          redirect_to '/testsuites/' + (@suitetype ? @suitetype.downcase : '')
        end
      end
    end
  end

  def show
  	begin
  		@test_run = TestRun.find(params[:id])
      @debug_vars = [@test_run]
  	rescue => e
  		flash[:danger] = "Failed to find TestRun ##{params[:id]}"
  		redirect_to controller: "test_suite", action: "index"
  	end
  	@suite = TestSuites.find(@test_run.test_suites_id)
  end

  def updatenotes
    @testrun = TestRun.find(params[:id])
    @testrun.comments = params[:comments]
    @testrun.save!
    redirect_to action: "show", id: params[:id]
  end

  # for launching a new pixel test

  def new
    logged_in_only do
      # set debug for javascript debugging to empty
      @debug_vars = []

      # Set to Sreejits email if no other present
      @default_email = Time.now.to_i.to_s + ".9fea5a75@mailosaur.in"

      # get the current logged in user if currently logged in
      if(current_user)
        @default_email = current_user.email if(current_user.username)
      end 
      if(params[:suitetype] != nil)
        @browsers  = Browsertypes.where(active: 1)
      end

      # get all the tests available
      @pixeltests = PixelTest.all().where(:suitetype => params[:suitetype])

      # push these to debug variable
      @debug_vars.push(@pixeltests)

      # get all test urls for this first test
      @test_urls = @pixeltests.first.test_urls if @test_urls
    end
  end

  def get_data_for_testing

  end

end
