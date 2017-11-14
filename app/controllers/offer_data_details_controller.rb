class OfferDataDetailsController < ApplicationController
  before_action :set_offer_data_detail, only: [:show, :edit, :update, :destroy]

  # GET /offer_data_details
  # GET /offer_data_details.json
  def index
    @offer_data_details = OfferDataDetail.all
  end

  # GET /offer_data_details/1
  # GET /offer_data_details/1.json
  def show
  end

  # GET /offer_data_details/new
  def new
    @offer_data_detail = OfferDataDetail.new
  end

  # GET /offer_data_details/1/edit
  def edit
  end

  # POST /offer_data_details
  # POST /offer_data_details.json
  def create
    @offer_data_detail = OfferDataDetail.new(offer_data_detail_params)

    respond_to do |format|
      if @offer_data_detail.save
        log_action('Create', current_user ? current_user.username : 'Anonymous', @offer_data_detail[:id], 'OfferDataDetail')
        format.html { redirect_to @offer_data_detail, notice: 'Offer data detail was successfully created.' }
        format.json { render :show, status: :created, location: @offer_data_detail }
      else
        format.html { render :new }
        format.json { render json: @offer_data_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /offer_data_details/1
  # PATCH/PUT /offer_data_details/1.json
  def update
    respond_to do |format|
      if @offer_data_detail.update(offer_data_detail_params)
        log_action('Update', current_user ? current_user.username : 'Anonymous', params[:id], 'OfferDataDetail')
        format.html { redirect_to @offer_data_detail, notice: 'Offer data detail was successfully updated.' }
        format.json { render :show, status: :ok, location: @offer_data_detail }
      else
        format.html { render :edit }
        format.json { render json: @offer_data_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /offer_data_details/1
  # DELETE /offer_data_details/1.json
  def destroy
    @offer_data_detail.destroy
    log_action('Delete', current_user ? current_user.username : 'Anonymous', params[:id], 'OfferDataDetail')
    respond_to do |format|
      format.html { redirect_to offer_data_details_url, notice: 'Offer data detail was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_offer_data_detail
      @offer_data_detail = OfferDataDetail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def offer_data_detail_params
      params.require(:offer_data_detail).permit(:offer_title, :offerdesc, :offerdatum_id)
    end
end
