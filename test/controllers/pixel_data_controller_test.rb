require 'test_helper'

class PixelDataControllerTest < ActionController::TestCase
  setup do
		login_to_tetra
	end
	
	test "should get pixels" do
	    get :index, {}, { "Accept" => "application/json" }
	    assert_response :success
	    response_json = JSON.parse(response.body)
	    assert_not_nil response
  	end

  	test "should create pixel" do
	    post :create, :pixel_data => {
	  			:pixel_handle => 'testcreatepixel',
	  			:expected_state => 1,
	  			:test_url_id => 42
	  		}
	    assert_response :success
	    response_json = JSON.parse(response.body)
  	end
  	test "should destroy pixel_data" do
		new_pixel = PixelData.new()
		new_pixel.pixel_handle = 'testdeletepixel'
		new_pixel.save!
		assert_difference('PixelData.count', -1) do
			delete :delete, id: new_pixel.id
		end

		assert_response :success

		response_json = JSON.parse(response.body)
	end

  	test "should edit pixel" do
	    post :create, :pixel_data => {
	  			:pixel_handle => 'testeditpixel',
	  			:expected_state => 1,
	  			:test_url_id => 42
	  		}
	    assert_response :success
	    response_json = JSON.parse(response.body)

  		id_before = response_json['id']
	    post :update,:id => id_before, :pixel_data => {
	  			:pixel_handle => 'testeditedpixel',
	  		}
	    assert_response :success

	    response_json = JSON.parse(response.body)
	    changed_pixel = PixelData.find(id_before)
	    assert_equal changed_pixel.pixel_handle, 'testeditedpixel'
  	end
end
