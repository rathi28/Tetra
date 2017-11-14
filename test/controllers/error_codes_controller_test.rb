require 'test_helper'

class ErrorCodesControllerTest < ActionController::TestCase
  setup do
    @error_code = error_codes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:error_codes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create error_code" do
    assert_difference('ErrorCode.count') do
      post :create, error_code: { errorcode: @error_code.errorcode, human_name: @error_code.human_name }
    end

    assert_redirected_to error_code_path(assigns(:error_code))
  end

  test "should show error_code" do
    get :show, id: @error_code
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @error_code
    assert_response :success
  end

  test "should update error_code" do
    patch :update, id: @error_code, error_code: { errorcode: @error_code.errorcode, human_name: @error_code.human_name }
    assert_redirected_to error_code_path(assigns(:error_code))
  end

  test "should destroy error_code" do
    assert_difference('ErrorCode.count', -1) do
      delete :destroy, id: @error_code
    end

    assert_redirected_to error_codes_path
  end
end
