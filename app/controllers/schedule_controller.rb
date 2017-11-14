class ScheduleController < ApplicationController
  include ScheduleHelper
  def new
    admin_only do
      # get all the tests available
      @pixeltests = PixelTest.all().where(:suitetype => nil)
      # get all the tests available
      @vanitytests = PixelTest.all().where(:suitetype => 'vanity')
      # get all the tests available
      @ucitests = PixelTest.all().where(:suitetype => 'uci') 
      @seotests = PixelTest.all().where(:suitetype => 'seo')
      
      @test_urls = @pixeltests.first.test_urls if @pixeltests.first
      @vanity_test_urls = @vanitytests.first.test_urls if @vanitytests.first
      @uci_test_urls = @ucitests.first.test_urls if @ucitests.first
      @seo_test_urls = @seotests.first.test_urls if @seotests.first


      @browsers = Browsertypes.where(:active => "1")
      @brands = Brands.all()
      @testrun = Testrun.new()
      
      if(current_user)
        @default_email = current_user.email if(current_user.username)
      end 
    end
  end

  # Returns the View response for a Recurring test
  def show
    admin_only do
  	# get the schedule object to be shown.
	  @test = get_test_with_rescue
    @suite = TestSuites.where(:scheduleid => @test.id)
    end
  end

  # Creates a new entry for a Recurring test
  def create
  	# add actions here
    # This action takes place in the test suite controller
  end

  # Removes a recurring test from the rotation
  def delete
    admin_only do
  	# get the schedule object to be deleted.
      handle_recurring_schedule_failure 'remove', 'removed' do
        @test = get_test_with_rescue
        @test.destroy!
        flash[:success] = "Recurring Test Run Removed"
      end
      redirect_to action: "index"
      end
  end

  # Returns a edit form for the Recurring test given
  def edit
    admin_only do
    @brands= Brands.all
    @pixeltests = PixelTest.all()
  	# get the schedule object to be edited.
  	@test = get_test_with_rescue
    end
  end

  # Disables but does not remove the test given
  def disable
    admin_only do
    handle_recurring_schedule_failure 'disable', 'disabled' do
      # get the schedule object to be disabled.
      @test = get_test_with_rescue
      @test.active = nil
      @test.save!
    end
    redirect_to action: "index"
    end
  end

  # Enables disabled test
  def enable
    admin_only do
    begin
      # get the schedule object to be disabled.
      @test = get_test_with_rescue
      @test.active = 1
      @test.save!
      flash[:success] = "Recurring Test Run Enabled"
    rescue => e
      flash[:danger] = "Failed to enable Test"
    end
    redirect_to action: "index"
    end
  end

  # Returns the list of currently scheduled test cases and the currently active recurring tests.
  def index
    admin_only do
      @testruns = []
      @debug_vars = []
		# Set header message
		@headertext = "Scheduled Tests"
		# Return all scheduled tests
    @test_runs = TestRun.scheduled_tests.paginate(:page => params[:page_scheduled], :per_page => 10)
    @debug_vars.push(@test_runs)
		@testruns2 = Testrun.scheduled_tests.paginate(:page => params[:page_scheduled], :per_page => 10)
    @debug_vars.push(@testruns2)
    @testruns = @testruns2.concat @test_runs
		@recurring_tests = RecurringSchedule.all().paginate(:page => params[:page_recur], :per_page => 10)
  end
  end

  def run
    begin
      require_relative Rails.root.join("lib/grotto/import.rb")
      require_relative Rails.root.join("lib/grotto/browser/grid_utilities.rb")
      test_to_be_run = RecurringSchedule.where(id: params[:id])
      puts "test_to_be_run"
      puts test_to_be_run
      TestLauncher.new.setup_scheduled_test(test_to_be_run)
      flash[:success] = "Run Successfully Launched"
      redirect_to action: "show", id: params[:id]
    rescue => e
      flash[:danger] = "Failed to launch test - ID #{params[:id]}"
      redirect_to action: "index"
    end
  end

  # U of the CRUD actions
  def update
    # Protect from non-admin access
    admin_only do
      params[:weeklyday] = nil if params[:weeklyday] = ''
      @test = RecurringSchedule.find(params[:id])
      if @test.update(schedule_params)
        log_action('Update', current_user ? current_user.username : 'Anonymous', params[:id], 'RecurringSchedule')
        if params[:weeklyday].nil?
          @test.reload
          @test.weeklyday = nil
          @test.save
        end
        redirect_to action: "show", id: @test.id
      else
        render 'edit'
      end
    end
  end

  private
  def schedule_params
    params.require(:recurringschedule).permit(
      :grcid, 
      :brand,
      :driver,
      :platform,
      :customoffer,
      :customurl,
      :weeklyday,
      :dailyhour,
      :dailyminute,
      :name,
      :pixel_suite,
      :email,
      :realm
      )
  end
  def get_test_with_rescue
  	begin
  		# get the schedule object to be edited.
  		return RecurringSchedule.find(params[:id])
  	rescue ActiveRecord::RecordNotFound => e
  		# send error to user if campaign doesn't exist, was deleted.
  		flash[:danger] = "Schedule Test # #{params[:id]} could not be found"
  		redirect_to action: "index"
  	end
  end
end
