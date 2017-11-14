require 'test_helper'

class ApiTestUrlControllerTest < ActionController::TestCase	
	setup do
		login_to_tetra
	end
	
	test "should get urls" do
	    get :index, {}, { "Accept" => "application/json" }
	    assert_response :success
	    response_json = JSON.parse(response.body)
	    assert_not_nil response
  	end

  	test "should create url" do
  		request = {
  			
  		}.to_json
	    post :create, :test_url => {
	  			:url => 'http://wen.com/',
	  			:appendstring => 'testdelete',
	  			:testdata_id => 1
	  		}
	    assert_response :success
	    response_json = JSON.parse(response.body)
  	end
  	
  	test "should destroy url" do
		new_url = TestUrl.new()
		new_url.url = 'https://google.com'
		new_url.save!

		assert_difference('TestUrl.count', -1) do
			delete :delete, id: new_url.id
		end
		assert_response :success
		response_json = JSON.parse(response.body)
	end

  	test "should edit url" do
	    post :create, test_url: {
	  			:url => 'http://wen.com/',
	  			:appendstring => 'testupdate',
	  			:testdata_id => 1
	  		} 
	    assert_response :success
	    response_json = JSON.parse(response.body)

	   	id_before = response_json['id']
	    post :update, :id => id_before, :test_url => {
	  			:url => 'http://itcosmetics.com/'
	  		}
	    assert_response :success
	    response_json = JSON.parse(response.body)

	    changed_test = TestUrl.find(id_before)
	    assert_equal changed_test.url, 'http://itcosmetics.com/'
  	end
  end