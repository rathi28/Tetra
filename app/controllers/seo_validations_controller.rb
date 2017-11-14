class SeoValidationsController < ApplicationController
  before_action :set_seo_validation, only: [:show, :edit, :update, :destroy]

  # GET /seo_validations
  # GET /seo_validations.json
  def index
    @seo_validations = SeoValidation.all
  end

  # GET /seo_validations/1
  # GET /seo_validations/1.json
  def show
  end

  # GET /seo_validations/new
  def new
    @seo_validation = SeoValidation.new
  end

  # GET /seo_validations/1/edit
  def edit
  end

  # POST /seo_validations
  # POST /seo_validations.json
  def create
    @seo_validation = SeoValidation.new(seo_validation_params)

    respond_to do |format|
      if @seo_validation.save
        format.html { redirect_to @seo_validation, notice: 'Seo validation was successfully created.' }
        format.json { render :show, status: :created, location: @seo_validation }
      else
        format.html { render :new }
        format.json { render json: @seo_validation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /seo_validations/1
  # PATCH/PUT /seo_validations/1.json
  def update
    respond_to do |format|
      if @seo_validation.update(seo_validation_params)
        format.html { redirect_to @seo_validation, notice: 'Seo validation was successfully updated.' }
        format.json { render :show, status: :ok, location: @seo_validation }
      else
        format.html { render :edit }
        format.json { render json: @seo_validation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /seo_validations/1
  # DELETE /seo_validations/1.json
  def destroy
    @seo_validation.destroy
    respond_to do |format|
      format.html { redirect_to seo_validations_url, notice: 'Seo validation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_seo_validation
      @seo_validation = SeoValidation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def seo_validation_params
      params.require(:seo_validation).permit(:realm, :is_core, :page_name, :validation_type, :value, :present)
    end
end
