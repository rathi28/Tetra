class BrandurldataController < ApplicationController
  before_action :set_brandurldatum, only: [:show, :edit, :update, :destroy]

  # GET /brandurldata
  # GET /brandurldata.json
  def index
    admin_only do
      @brandurldata = Brandurldatum.all
    end
  end

  # GET /brandurldata/1
  # GET /brandurldata/1.json
  def show
    admin_only do

    end
  end

  # GET /brandurldata/new
  def new
    admin_only do
      @brandurldatum = Brandurldatum.new
    end
  end

  # GET /brandurldata/1/edit
  def edit
    admin_only do
    end
  end

  # POST /brandurldata
  # POST /brandurldata.json
  def create
    admin_only do
      @brandurldatum = Brandurldatum.new(brandurldatum_params)

      respond_to do |format|
        if @brandurldatum.save
          log_action('Create', current_user ? current_user.username : 'Anonymous', @brandurldatum[:id], 'BrandUrlData')
          format.html { redirect_to @brandurldatum, notice: 'Brandurldatum was successfully created.' }
          format.json { render :show, status: :created, location: @brandurldatum }
        else
          format.html { render :new }
          format.json { render json: @brandurldatum.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /brandurldata/1
  # PATCH/PUT /brandurldata/1.json
  def update
    admin_only do
      respond_to do |format|
        if @brandurldatum.update(brandurldatum_params)
          log_action('Update', current_user ? current_user.username : 'Anonymous', params[:id], 'BrandUrlData')
          format.html { redirect_to @brandurldatum, notice: 'Brandurldatum was successfully updated.' }
          format.json { render :show, status: :ok, location: @brandurldatum }
        else
          format.html { render :edit }
          format.json { render json: @brandurldatum.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /brandurldata/1
  # DELETE /brandurldata/1.json
  def destroy
    admin_only do
      @brandurldatum.destroy
      log_action('Delete', current_user ? current_user.username : 'Anonymous', params[:id], 'BrandUrlData')
      respond_to do |format|
        format.html { redirect_to brandurldata_url, notice: 'Brandurldatum was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_brandurldatum
      @brandurldatum = Brandurldatum.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def brandurldatum_params
      params.require(:brandurldatum).permit(:brand, :development, :stg, :qa, :prod, :test_env)
    end
end
