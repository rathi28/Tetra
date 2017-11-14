class SeoFilesController < ApplicationController
  before_action :set_seo_file, only: [:show, :edit, :update, :destroy]

  # GET /seo_files
  # GET /seo_files.json
  def index
    @seo_files = SeoFile.all
  end

  # GET /seo_files/1
  # GET /seo_files/1.json
  def show
  end

  # GET /seo_files/new
  def new
    @seo_file = SeoFile.new
  end

  # GET /seo_files/1/edit
  def edit
  end

  # POST /seo_files
  # POST /seo_files.json
  def create
    @seo_file = SeoFile.new(seo_file_params)

    respond_to do |format|
      if @seo_file.save
        format.html { redirect_to @seo_file, notice: 'Seo file was successfully created.' }
        format.json { render :show, status: :created, location: @seo_file }
      else
        format.html { render :new }
        format.json { render json: @seo_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /seo_files/1
  # PATCH/PUT /seo_files/1.json
  def update
    respond_to do |format|
      if @seo_file.update(seo_file_params)
        format.html { redirect_to @seo_file, notice: 'Seo file was successfully updated.' }
        format.json { render :show, status: :ok, location: @seo_file }
      else
        format.html { render :edit }
        format.json { render json: @seo_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /seo_files/1
  # DELETE /seo_files/1.json
  def destroy
    @seo_file.destroy
    respond_to do |format|
      format.html { redirect_to seo_files_url, notice: 'Seo file was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_seo_file
      @seo_file = SeoFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def seo_file_params
      params.require(:seo_file).permit(:filename, :domain, :targeturl, :valid_content)
    end
end
