class ApiTestUrlController < ApplicationController
  def index
    	testurls = TestUrl.all()
    	render json: testurls
  end

  def suite
    testurls = PixelTest.find(params[:id]).test_urls
    response_json = []
    testurls.each do |url|
      pixels = nil
      pixels = PixelData.where(test_url_id: url.id)
      response_json.push({url: url, pixels: pixels})
    end
    render json: response_json
  end
 
  def delete
    admin_only do
    	url = TestUrl.find(params[:id])
    	url.delete
    	response = {url.id => 'Deleted'}
    	render json: response
    end
  end

  def create
    admin_only do
    	new_url = TestUrl.new(test_url_params)
      new_url.page_type = "Content Page"
      new_url.realm = "Realm1"
    	new_url.save!
    	render json: new_url
    end
  end

  def update
    admin_only do
    	update_url = TestUrl.find(params[:id])
    	update_url.update(test_url_params)
    	update_url.save!
    	render json: update_url
    end
  end

  def show
  end
  
  private
  def test_url_params
  	params.require(:test_url).permit(
      :url,
      :testdata_id,
      :mode,
      :appendstring,
      :page_type,
      :mmtest,
      :pixel_test_id,
      :uci,
      :offercode,
      :campaign,
      :realm,
      :is_core
      )
  end
end
