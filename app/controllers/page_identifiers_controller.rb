class PageIdentifiersController < ApplicationController
  before_action :set_page_identifier, only: [:show, :edit, :update, :destroy]

  # GET /page_identifiers
  # GET /page_identifiers.json
  def index
    @page_identifiers = PageIdentifier.all
  end

  # GET /page_identifiers/1
  # GET /page_identifiers/1.json
  def show
  end

  # GET /page_identifiers/new
  def new
    @page_identifier = PageIdentifier.new
  end

  # GET /page_identifiers/1/edit
  def edit
  end

  # POST /page_identifiers
  # POST /page_identifiers.json
  def create
    @page_identifier = PageIdentifier.new(page_identifier_params)

    respond_to do |format|
      if @page_identifier.save
        format.html { redirect_to @page_identifier, notice: 'Page identifier was successfully created.' }
        format.json { render :show, status: :created, location: @page_identifier }
      else
        format.html { render :new }
        format.json { render json: @page_identifier.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /page_identifiers/1
  # PATCH/PUT /page_identifiers/1.json
  def update
    respond_to do |format|
      if @page_identifier.update(page_identifier_params)
        format.html { redirect_to @page_identifier, notice: 'Page identifier was successfully updated.' }
        format.json { render :show, status: :ok, location: @page_identifier }
      else
        format.html { render :edit }
        format.json { render json: @page_identifier.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /page_identifiers/1
  # DELETE /page_identifiers/1.json
  def destroy
    @page_identifier.destroy
    respond_to do |format|
      format.html { redirect_to page_identifiers_url, notice: 'Page identifier was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_page_identifier
      @page_identifier = PageIdentifier.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def page_identifier_params
      params.require(:page_identifier).permit(:page, :value)
    end
end
