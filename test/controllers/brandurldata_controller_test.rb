require 'test_helper'

class BrandurldataControllerTest < ActionController::TestCase
  setup do
    login_to_tetra
    @brandurldatum = brandurldata(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:brandurldata)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create brandurldatum" do
    brandurldata(:one).destroy!
    assert_difference('Brandurldatum.count') do
      post :create, brandurldatum: { brand: @brandurldatum.brand, development: @brandurldatum.development, prod: @brandurldatum.prod, qa: @brandurldatum.qa, test_env: @brandurldatum.test_env }
    end

    assert_redirected_to brandurldatum_path(assigns(:brandurldatum))
  end

  test "should show brandurldatum" do
    get :show, id: @brandurldatum
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @brandurldatum
    assert_response :success
  end

  test "should update brandurldatum" do
    patch :update, id: @brandurldatum, brandurldatum: { brand: @brandurldatum.brand, development: @brandurldatum.development, prod: @brandurldatum.prod, qa: @brandurldatum.qa, test_env: @brandurldatum.test_env }
    assert_redirected_to brandurldatum_path(assigns(:brandurldatum))
  end

  test "should destroy brandurldatum" do
    assert_difference('Brandurldatum.count', -1) do
      delete :destroy, id: @brandurldatum
    end

    assert_redirected_to brandurldata_path
  end
end
