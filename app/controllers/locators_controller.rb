class LocatorsController < ApplicationController
  include LocatorsHelper
  before_action :set_locator, only: [:show, :edit, :update, :destroy]

  # GET /Locator
  # GET /Locator.json
  def index
    if(params[:search])
      case params[:type]
      when "brand"
        @locators = search(params[:type],params[:searchcontent])
      when "css"
        @locators = search(params[:type], params[:searchcontent])
      when "offer"
        @locators = search(params[:type], params[:searchcontent])
      when "step"
        @locators = search(params[:type], params[:searchcontent])
      end
    else
      @locators = Locator.where(nil)
      # Filter parameters that we want to sort by out of hash, and then set the request to only these values
      filtering_params(params).each do |key, value|
          @locators = @locators.public_send(key, value) if value.present?
      end
    end
    @locators = @locators.all.paginate(:page => params[:page], :per_page => 7)
  end

  # GET /Locator/1
  # GET /Locator/1.json
  def show
  end

  # GET /Locator/new
  def new
    @locator = Locator.new
  end

  # GET /Locator/1/edit
  def edit
  end

  def previewimport
    parse_imports(params)
  end

  def import
    params[:locators].each do |id, locator|
      begin
        locator_obj       = Locator.new()
        locator_obj.css   = locator[:css]
        locator_obj.brand = locator[:brand]
        locator_obj.step  = locator[:step]
        locator_obj.offer = locator[:offer]
        locator_obj.save!
      rescue => e
        flash[:danger] += e.message + " - " + locator[:css]
      end
    end
    redirect_to action: "index"
  end

  # POST /Locator
  # POST /Locator.json
  def create
    @locator = Locator.new(locator_params)

    respond_to do |format|
      if @locator.save
        log_action('Create', current_user ? current_user.username : 'Anonymous', @locator[:id], 'Locator')
        format.html { redirect_to @locator, notice: 'Locator was successfully created.' }
        format.json { render :show, status: :created, location: @locator }
      else
        format.html { render :new }
        format.json { render json: @locator.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /Locator/1
  # PATCH/PUT /Locator/1.json
  def update
    respond_to do |format|
      if @locator.update(locator_params)
        log_action('Update', current_user ? current_user.username : 'Anonymous', params[:id], 'Locator')
        format.html { redirect_to @locator, notice: 'Locator was successfully updated.' }
        format.json { render :show, status: :ok, location: @locator }
      else
        format.html { render :edit }
        format.json { render json: @locator.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /Locator/1
  # DELETE /Locator/1.json
  def destroy
    @locator.destroy
    log_action('Delete', current_user ? current_user.username : 'Anonymous', params[:id], 'Locator')
    respond_to do |format|
      format.html { redirect_to locators_path, flash: {success: 'Locator was successfully destroyed.'} }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_locator
      @locator = Locator.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def locator_params
      params.require(:locator).permit(:css, :brand, :step, :offer)
    end

    # Campaign filtering limiter
    def filtering_params(params)
      params.slice(:css, :brand, :step, :offer)
    end

    ##
    # Parses imports for the Pixel tests
    def parse_imports(params)
      data = params[:rawdata]
      rows = data.split(/[\n\r]+/)
      rowsandcolumns = []


      rows.each do |row|
        columns = row.split("\t")
        rowsandcolumns.push columns
      end

      @data = rowsandcolumns
  end
end
