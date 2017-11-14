class CampaignsController < ApplicationController
  def index
    if params[:format] != 'json'
      # Protect from non-admins
      admin_only do
        # request list of all brands for page
        @brands = Brands.all()

        # set header messsage
      	@headertext = "Campaigns"

        # create an ActiveRecord request object
        @campaigns = Campaign.where(nil)

        # Filter parameters that we want to sort by out of hash, and then set the request to only these values
        filtering_params(params).each do |key, value|
          	@campaigns = @campaigns.public_send(key, value) if value.present?
        end

        # Get unique list of campaigns to be listed
        @campaign_list = @campaigns.select(:grcid).map(&:grcid).uniq

        # Get unique list of environments to be listed
        @environment_list = @campaigns.select(:environment).map(&:environment).uniq
        
        # Get unique list of realms to be listed
        @realm_list = @campaigns.select(:realm).map(&:realm).uniq

        # TODO[Cleanup] - remove this?
        # get the unique list of UCIs to be listed
        @ucis = Campaign.select(:uci).map(&:uci).uniq

        # Get campaigns for the page, limiting list to 7 per page
        @campaigns = @campaigns.paginate(:page => params[:page], :per_page => 7)
      end 
    else
      # create an ActiveRecord request object
      @campaigns = Campaign.where(nil)

      # Filter parameters that we want to sort by out of hash, and then set the request to only these values
      filtering_params(params).each do |key, value|
          @campaigns = @campaigns.public_send(key, value) if value.present?
      end
    end
  end

  # C of the CRUD actions - creates a new campaign from the parameters
  def create
    # Protect from non-admin access
    admin_only do
      begin
        # create campaign object from parameters given

        @campaign = Campaign.new(campaign_params)
        @campaign.environment = @campaign.environment.downcase
        if @campaign[:realm] == nil || @campaign[:realm] == ""
          raise "Campaign needs Realm"
        end

        # save object to database
        @campaign.save

        log_action('Create', current_user ? current_user.username : 'Anonymous', @campaign.id, 'Campaign')

        # send the user a successful flash message
        flash[:success] = "Campaign created successfully!"

        # send user to the newly create campaigns show page
        redirect_to @campaign
      rescue => e
        flash[:danger] = "Campaign could not created - #{e.message}"
        redirect_to action: "index"
      end
    end
  end

  # D of the CRUD actions
  def destroy
    # Protect from non-admin access
    admin_only do
      begin
        @campaign = Campaign.find(params[:id])
        @campaign.destroy!
        log_action('Delete', current_user ? current_user.username : 'Anonymous', params[:id], 'Campaign')
        flash[:success] = "Campaign deleted successfully!"
      rescue => e
        flash[:danger] = "Campaign could not be deleted: #{e.message}"
      end
      redirect_to action: "index"
    end
  end

  # Create a new object for campaign creation form
  def new
    # Protect from non-admin access
    admin_only do
      # get all the brands we need to put in form
      @brands = Brands.all()
      # get the initial campaigns needed
      @campaign = Campaign.new()
    end
  end

  # Duplicate existing campaign by ID, and then send user to the edit page for that campaign
  def duplicate
    # Protect from non-admin access
    admin_only do
      begin
        # find the campaign to be duplicated
        @original = Campaign.find(params[:id])

        # call duplication method, which returns a new Campaigns object
        @duplicate = @original.dup

        # save the new campaign configuration
        @duplicate.save!

        # stpre the duplicated message into edit page variable
        @campaign = @duplicate

        # send user success message
        flash[:success] = "Campaign cloned successfully!"

        log_action('Duplicate', current_user ? current_user.username : 'Anonymous', params[:id] , 'Campaign')
        log_action('Create', current_user ? current_user.username : 'Anonymous', @duplicate.id , 'Campaign')

        # redirect user to edit page
        redirect_to edit_campaign_path(@duplicate)

      rescue => e
        # send user error message, overides for system error messages should be done here if needed.
        flash[:danger] = "Campaign could not be cloned: #{e.message}"
        redirect_to action: "index"
      end
    end
  end

  # U of the CRUD actions
  def update
    # Protect from non-admin access
    admin_only do
      if params[:id]
        @campaign = Campaign.find(params[:id])
      end
      log_action('Update', current_user ? current_user.username : 'Anonymous', params[:id], 'Campaign')
      if @campaign.update(campaign_params)
        @campaign.environment = @campaign.environment.downcase
        @campaign.save!
        redirect_to @campaign
      else
        render 'edit'
      end
    end
  end

  # R of the CRUD actions
  def show
    # Protect from non-admin access
    admin_only do
    	begin
        # set the default value for platform if it isn't set
        params['platform'] = 'desktop' if params['platform'].nil? 

        # get campaign by id
        @campaign = Campaign.find(params[:id])

        # get list of all brands available
        @brands = Brands.all()

        # Get offers currently associated with this campaign/environment/platform/brand
        @offers   = @campaign.offerdata
      rescue ActiveRecord::RecordNotFound => e
        # send error to user if campaign doesn't exist, was deleted.
        flash[:danger] = "Campaign # #{params[:id]} could not be found"
        redirect_to action: "index"
      end
    end
  end

  def edit
    # Protect from non-admin access
    admin_only do
      # get list of all brands available
      @brands = Brands.all()
      begin
        # get the campaign object to be edited.
        @campaign = Campaign.find(params[:id])

      rescue ActiveRecord::RecordNotFound => e
        # send error to user if campaign doesn't exist, was deleted.
        flash[:danger] = "Campaign # #{params[:id]} could not be found"
        redirect_to action: "index"
      end
    end
  end

  private

  # campaign creation fields restrictions
  def campaign_params
    params.require(:campaigns).permit(
      :grcid, 
      :Brand, 
      :DesktopBuyflow,
      :DesktopHomePageTemplate,
      :DesktopCartPageTemplate, 
      :DesktopSASPagePattern, 
      :DesktopSASTemplate,
      :UCI,
      :default_offercode,
      :testenabled,
      :environment,
      :experience,
      :comments,
      :qaurl,
      :produrl,
      :expectedvitamin,
      :realm,
      :is_test_panel
      )
  end
  # Campaign filtering limiter
  def filtering_params(params)
    params.slice(:uci, :brand, :campaign, :environment, :platform, :realm)
  end

  #get all campaigns
  def migrate_campaign_id
    campaigns = Campaign.all()
    campaigns.each do |campaign|
      offers = Offerdatum.where(:Brand => campaign.Brand, campaign.experience.to_sym => '1', campaign.environment.to_sym => '1').where("campaign = ?", campaign.grcid)
      offers.each do |offer|
        offer.campaign_id = campaign.id
        offer.save!
      end
    end
  end
end

