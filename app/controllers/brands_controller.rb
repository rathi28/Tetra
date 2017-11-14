class BrandsController < ApplicationController
  before_action :set_brand, only: [:show, :edit, :update, :destroy]

  # GET /brands
  # GET /brands.json
  def index
    admin_only do
      @brands = Brand.all
    end
  end

  # GET /brands/1
  # GET /brands/1.json
  def show
    admin_only do

    end
  end

  # GET /brands/new
  def new
    # Protect from non-admins
    admin_only do
      @brand = Brand.new
    end
  end

  # GET /brands/1/edit
  def edit
    admin_only do
      
    end
  end

  # POST /brands
  # POST /brands.json
  def create
    admin_only do
      @brand = Brand.new(brand_params)

      respond_to do |format|
        if @brand.save
          format.html { redirect_to @brand, notice: 'Brand was successfully created.' }
          format.json { render :show, status: :created, location: @brand }

          # log this event
          log_action('Create', current_user.username, @brand.id, 'Brand')
        else
          format.html { render :new }
          format.json { render json: @brand.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /brands/1
  # PATCH/PUT /brands/1.json
  def update
    respond_to do |format|
      if @brand.update(brand_params)
        log_action('Update', current_user.username, @brand.id, 'Brand')
        format.html { redirect_to @brand, notice: 'Brand was successfully updated.' }
        format.json { render :show, status: :ok, location: @brand }
      else
        format.html { render :edit }
        format.json { render json: @brand.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /brands/1
  # DELETE /brands/1.json
  def destroy
    admin_only do
      @brand.destroy
      # log this event
      log_action('Destroy', current_user.username, @brand.id, 'Brand')

      respond_to do |format|
        format.html { redirect_to brands_url, notice: 'Brand was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_brand
      @brand = Brand.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def brand_params
      params.require(:brand).permit(:Brandname)
    end
end
