require 'test_helper'

class BrowsertypesControllerTest < ActionController::TestCase
  setup do
    login_to_tetra
    @browsertype = browsertypes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:browsertypes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create browsertype" do
    browsertypes(:one).destroy!
    assert_difference('Browsertype.count') do
      post :create, browsertype: { active: @browsertype.active, browser: @browsertype.browser, device_type: @browsertype.device_type, human_name: @browsertype.human_name, remote: @browsertype.remote }
    end

    assert_redirected_to browsertype_path(assigns(:browsertype))
  end

  test "should show browsertype" do
    get :show, id: @browsertype
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @browsertype
    assert_response :success
  end

  test "should update browsertype" do
    patch :update, id: @browsertype, browsertype: { active: @browsertype.active, browser: @browsertype.browser, device_type: @browsertype.device_type, human_name: @browsertype.human_name, remote: @browsertype.remote }
    assert_redirected_to browsertype_path(assigns(:browsertype))
  end

  test "should destroy browsertype" do
    assert_difference('Browsertype.count', -1) do
      delete :destroy, id: @browsertype
    end

    assert_redirected_to browsertypes_path
  end
end
