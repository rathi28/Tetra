class OfferdataController < ApplicationController
  # assemble data for offer data view page
  def index
    @debug_vars = {}
  	@headertext = "Offer Codes"
  	@offers = Offerdatum.where(nil)
  	filtering_params(params).each do |key, value|

  		# Parsing non-standard table values
  		if(key == 'environment')
  			key = value.to_sym
  			value = 1
  		end
  		if(key == 'platform')
  			key = value.to_sym
  			value = 1
  		end

      # filter the data
      @offers = @offers.public_send(key, value) if value.present?
    end
  	@campaign_list = @offers.all.select(:grcid).map(&:grcid).uniq
  	@brands = Brands.all()
    @offers = @offers.paginate(:page => params[:page], :per_page => 15)
    @debug_vars[:offers]    = @offers
    @debug_vars[:campaigns] = @campaign_list
    @debug_vars[:brands]    = @brands
  end

  # Finalize the offer update and submit to database.
  def update
  	begin
      @campaign_obj = Campaign.find(params[:prevpage])
	  	@campaign 	 = params[:grcid]
	  	@env 		     = params[:env]
	  	@brand 		   = params[:brand]
	  	@platform 	 = params[:platform]
	  	@imported_data 	= params[:offerdata]

	  	begin
		  	@offers = Offerdatum.where(
		  		:brand => @brand, 
		  		:grcid => @campaign, 
		  		@platform => 1, 
		  		@env => 1
		  		)
        log_action('Update', current_user ? current_user.username : 'Anonymous', @offers.ids.to_sentence, 'Offerdata')
		  	@offers.update_all(@env => 0)
		rescue

		end
	  	@parsed_data 	= @imported_data.split("\n")
	  	@final = []
      
	  	@parsed_data.each do |item|
	  		item = item.split("\t")
	  		item.each do |entry|
	  			entry.strip!
	  		end
	  		if(item[0] != "OfferCode")
		  		@final.push(item)
		  	end
	  	end
      @campaign_obj.offerdata.delete_all

	  	@final.each do |offer|
        vitamin = 0
        vitamin = 1 if(offer[4].downcase.include? 'vitamin')
	  		new_offer = Offerdatum.new()
	  		new_offer.update(
	  			:OfferCode => offer[0],
	  			:SupplySize => offer[1],
	  			:PieceCount => offer[2],
	  			:Bonus => offer[3],
	  			:Offer => offer[4],
	  			:ExtraStep => offer[11],
	  			:Entry => offer[5],
	  			:Continuity => offer[6],
	  			:StartSH => offer[7],
	  			:ContinuitySH => offer[8],
	  			:Rush => offer[9],
	  			:OND => offer[10],
          :isvitamin => vitamin,
          :campaign => @campaign_obj
	  			)

	  		new_offer.save!
        log_action('Create', current_user ? current_user.username : 'Anonymous', new_offer.id, 'Offerdata')
	  	end
  		flash[:success] = "Offers Imported Successfully!"
    rescue => e
      flash[:danger] = "There was a problem with Offerdatum. Go back to attempt to correct it: #{e.message}"
    end
    
    if(params[:prevpage].empty?)
      params[:environment] = params[:env]
    	redirect_to action: "index", params: filtering_params(params)
    else
      redirect_to action: "show", controller: "campaigns", id: params[:prevpage]
    end
  end
  
  # unused import new data page (replaced by inline offer form from filter view)
  def import
  	@brands = Brands.all()
  end

  # creates a preview page based on data to be parsed
  def preview
    # Needed to carry a previous campaign ID through for redirect back to campaign once complete. 
    @campaign_id = params[:campaign_id] 

    # pull in the values from parameters
  	@campaign 	= params[:grcid]
  	@env 		= params[:env]
  	@brand 		= params[:brand]
  	@platform 	= params[:platform]

    # pull in the imported text from field
  	@imported_data 	= params[:offerdata]

    # split data on new lines (breaks data into rows)
  	@parsed_data 	= @imported_data.split("\n")

    # create empty preview collection for preview page (holds rows)
  	@preview = [] 
  	@parsed_data.each do |item|
      # split data on tabs (breaks rows into cells)
  		item = item.split("\t")
  		item.each do |entry|
        # clean up whitespace
  			entry.strip! 
  		end

  		if(item[0] != "OfferCode") # ignore headers if present
	  		@preview.push(item) # submit row to preview collection
	  	end
  	end
  end # end of preview function

  # removes offercodes from campaign configuration
  def deactivatecodes
  	@campaign 	= params[:grcid]
  	@env 		= params[:env]
  	@brand 		= params[:brand]
  	@platform 	= params[:platform]

  	@offers = Offerdatum.where(
  		:brand => @brand, 
  		:grcid => @campaign, 
  		@platform => 1, 
  		@env => 1
  		)

  	@offers.update_all(@env => 0, @platform => 0)
  end # end of deactivatecodes function

  private 
  # Following Methods are not actions for controller, they are support methods

  # Offerdata filtering limiter
	def filtering_params(params)
	  params.slice(:brand, :grcid, :platform, :environment)
	end # end of filtering_params function

end