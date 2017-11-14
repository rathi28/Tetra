class TestrunsController < ApplicationController
  ##
  # Overview of all test runs - Not linked by any page, and not checked for functionality
  def index
	if params[:suitetype]
      header = params[:suitetype]
    else
      header = ""
    end
  	@headertext = header + " Test Runs"
  	@testruns = Testrun.where(nil).paginate(:page => params[:page]).order('id DESC')
    filtering_params(params).each do |key, value|
      @testruns = @testruns.public_send(key, value) if value.present?
    end
  end

  ##
  # Shows a test run object and its current status, and shows its results matched against its expected data.
  # @debug_vars is automatically placed on all pages as the variable_obj javascript variable. add anything you want put on the javascript variable to this variable.
  def show
    @headertext = "Test Run"
    @debug_vars = []
    offercode_array = []
    @offer = []
  	begin
      @testrun = Testrun.find(params[:id])
      @suite = TestSuites.find(@testrun.test_suites_id)
      @campaign = Campaign.where(:Brand => @testrun['Brand'], :grcid => @testrun.expectedcampaign, :environment => @testrun.Env, :experience => @testrun.DriverPlatform, :realm => @testrun.realm)
      @campaign.where(realm: @testrun.realm) if(@testrun.realm != nil)
      if(@testrun['ExpectedOffercode'].include? (';'))
        offercode_array = @testrun['ExpectedOffercode'].split(';')
      else
        offercode_array.push(@testrun['ExpectedOffercode'])
      end
      offercode_array.each do |entry|
        puts "enter array calculation"
        offer_entry = @campaign.first.offerdata.where('OfferCode' => entry)
        @offer.push(offer_entry)
      end
      # @offer = @campaign.first.offerdata.where('OfferCode' => @testrun['ExpectedOffercode']) if(@testrun['ExpectedOffercode'])
      @vitamin = Offerdatum.where('OfferCode' => @testrun['vitaminexpected']) if(@testrun['vitaminexpected'])
      @next = Testrun.where(:test_suites_id => @suite.id).where("id > ?", params[:id]).order(:id).first
      @previous = Testrun.where(:test_suites_id => @suite.id).where("id < ?", params[:id]).order(:id).last
      @debug_vars.push(@vitamin)
      @debug_vars.push(@offer)
      @debug_vars.push(@testrun)
      @debug_vars.push(@suite)
      
    rescue ActiveRecord::RecordNotFound => e
      flash[:danger] = "Test run #{params[:id]} could not be found - #{e.message}"
      redirect_to action: "index"
    end
  end

  def updatenotes
    @testrun = Testrun.find(params[:id])
    @testrun.comments = params[:comments]
    @testrun.save!
    redirect_to action: "show", id: params[:id]
  end

  ##
  # This isn't used, look for this functionality in TestSuitesController
  def create
    #test =TestLauncher.new()
    #test.run(params[:brand], params[:campaign], params[:server], params[:browser], params[:platform], params[:custom_url], params[:custom_offer])
    flash[:danger] = "Failed - bad route"
    redirect_to action: "index"
  end

  ##
  # generates the new run page for buyflow tests
  def new()
    logged_in_only do
      @headertext = "Test Launcher"
      @type = params[:type]
      @browsers = Browsertypes.where(:active => "1")
      @brands = Brands.all()
      @testrun = Testrun.new()
      if(current_user)
        @default_email = current_user.email if(current_user.username)
      end 
    end
  end

  # simple queue showing the test cases waiting to be run
  # @deprecated Not visible to public, but left in for anyone who knows how to find it for now. Could be removed at any time
  def simple_queue
    @headertext = "Test Case Queue"
    @testruns = Testrun.where(:result => 'waiting').paginate(:page => params[:page])
    filtering_params(params).each do |key, value|
      @testruns = @testruns.public_send(key, value) if value.present?
    end
    render action: "index"
  end

  
  private
  # Testrun filtering limiter
  def filtering_params(params)
    params.slice(:ranby, :brand, :offercode)
  end
end