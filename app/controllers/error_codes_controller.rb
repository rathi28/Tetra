class ErrorCodesController < ApplicationController
  before_action :set_error_code, only: [:show, :edit, :update, :destroy]

  # GET /error_codes
  # GET /error_codes.json
  def index
    @error_codes = ErrorCode.all
  end

  # GET /error_codes/1
  # GET /error_codes/1.json
  def show
  end

  # GET /error_codes/new
  def new
    @error_code = ErrorCode.new
  end

  # GET /error_codes/1/edit
  def edit
  end

  # POST /error_codes
  # POST /error_codes.json
  def create
    @error_code = ErrorCode.new(error_code_params)

    respond_to do |format|
      if @error_code.save
        log_action('Create', current_user ? current_user.username : 'Anonymous', @error_code[:id], 'Error Code')
        format.html { redirect_to @error_code, notice: 'Error code was successfully created.' }
        format.json { render :show, status: :created, location: @error_code }
      else
        format.html { render :new }
        format.json { render json: @error_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /error_codes/1
  # PATCH/PUT /error_codes/1.json
  def update
    respond_to do |format|
      if @error_code.update(error_code_params)
        log_action('Update', current_user ? current_user.username : 'Anonymous', params[:id], 'Error Code')
        format.html { redirect_to @error_code, notice: 'Error code was successfully updated.' }
        format.json { render :show, status: :ok, location: @error_code }
      else
        format.html { render :edit }
        format.json { render json: @error_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /error_codes/1
  # DELETE /error_codes/1.json
  def destroy
    @error_code.destroy
    log_action('Delete', current_user ? current_user.username : 'Anonymous', params[:id], 'Error Code')
    respond_to do |format|
      format.html { redirect_to error_codes_url, notice: 'Error code was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_error_code
      @error_code = ErrorCode.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def error_code_params
      params.require(:error_code).permit(:human_name, :errorcode)
    end
end
