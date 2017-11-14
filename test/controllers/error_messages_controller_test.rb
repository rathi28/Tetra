require 'test_helper'

class ErrorMessagesControllerTest < ActionController::TestCase
  setup do
    login_to_tetra
    @error_message = error_messages(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:error_messages)
  end

  test "should show error_message" do
    get :show, id: @error_message
    assert_response :success
  end
end
