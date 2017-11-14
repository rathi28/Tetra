class BrowsertypesController < ApplicationController
  before_action :set_browsertype, only: [:show, :edit, :update, :destroy]

  # GET /browsertypes
  # GET /browsertypes.json
  def index
    admin_only do
      @browsertypes = Browsertype.all
    end
  end

  # GET /browsertypes/1
  # GET /browsertypes/1.json
  def show
    admin_only do
    end
  end

  # GET /browsertypes/new
  def new
    admin_only do
      @browsertype = Browsertype.new
    end
  end

  # GET /browsertypes/1/edit
  def edit
    admin_only do
    end
  end

  # POST /browsertypes
  # POST /browsertypes.json
  def create
    admin_only do
      @browsertype = Browsertype.new(browsertype_params)

      respond_to do |format|
        if @browsertype.save
          log_action('Create', current_user ? current_user.username : 'Anonymous', @browsertype[:id], 'BrowserType')
          format.html { redirect_to @browsertype, notice: 'Browsertype was successfully created.' }
          format.json { render :show, status: :created, location: @browsertype }
        else
          format.html { render :new }
          format.json { render json: @browsertype.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /browsertypes/1
  # PATCH/PUT /browsertypes/1.json
  def update
    admin_only do
      respond_to do |format|
        if @browsertype.update(browsertype_params)
          log_action('Update', current_user ? current_user.username : 'Anonymous', params[:id], 'BrowserType')
          format.html { redirect_to @browsertype, notice: 'Browsertype was successfully updated.' }
          format.json { render :show, status: :ok, location: @browsertype }
        else
          format.html { render :edit }
          format.json { render json: @browsertype.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /browsertypes/1
  # DELETE /browsertypes/1.json
  def destroy
    admin_only do
      @browsertype.destroy
      log_action('Delete', current_user ? current_user.username : 'Anonymous', params[:id], 'BrowserType')
      respond_to do |format|
        format.html { redirect_to browsertypes_url, notice: 'Browsertype was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_browsertype
      @browsertype = Browsertype.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def browsertype_params
      params.require(:browsertype).permit(:browser, :device_type, :remote, :human_name, :active)
    end
end
