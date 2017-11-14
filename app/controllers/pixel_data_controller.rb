class PixelDataController < ApplicationController
  def index
    admin_only do
  	pixels = PixelData.all()
  	render json: pixels
    end
  end

  def for_url
    admin_only do
  	pixels = PixelData.where(test_url_id: params[:urlid].to_i)
  	render json: pixels
    end
  end

  def delete
    admin_only do
  	pixeldata = PixelData.find(params[:id])
  	pixeldata.destroy
    log_action('Delete', current_user ? current_user.username : 'Anonymous', params[:id], 'PixelData')
  	response = {pixeldata.id => 'Deleted'}
  	render json: response
    end
  end

  def delete_by_url
    admin_only do
    	pixeldata = PixelData.where(test_url_id: params[:urlid], pixel_handle: params[:pixelname])
    	pixeldata.destroy_all
      log_action('Destroy All Pixels', current_user ? current_user.username : 'Anonymous', params[:urlid], 'TestUrl')
  	response = {'deleted' => pixeldata}
  	render json: response
    end
  end

  def create
    admin_only do
  	new_pixel = PixelData.new(test_pixel_params)
  	new_pixel.save!
    log_action('Create', current_user ? current_user.username : 'Anonymous', new_pixel[:id], 'PixelData')
  	render json: new_pixel
    end
  end

  def update
    admin_only do
    	update_pixel = PixelData.find(params[:id])
    	update_pixel.update(test_pixel_params)
    	update_pixel.save!
      log_action('Update', current_user ? current_user.username : 'Anonymous', params[:id], 'PixelData')
  	   render json: update_pixel
    end
  end

  def show
    admin_only do

    end
  end


  private
  def test_pixel_params
  	params.require(:pixel_data).permit(
      :pixel_handle,
      :expected_state,
      :test_url_id
      )
  end
end
