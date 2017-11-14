require 'test_helper'

class SeoValidationsControllerTest < ActionController::TestCase
  setup do
    @seo_validation = seo_validations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:seo_validations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create seo_validation" do
    assert_difference('SeoValidation.count') do
      post :create, seo_validation: { page_name: @seo_validation.page_name, present: @seo_validation.present, validation_type: @seo_validation.validation_type, value: @seo_validation.value }
    end

    assert_redirected_to seo_validation_path(assigns(:seo_validation))
  end

  test "should show seo_validation" do
    get :show, id: @seo_validation
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @seo_validation
    assert_response :success
  end

  test "should update seo_validation" do
    patch :update, id: @seo_validation, seo_validation: { page_name: @seo_validation.page_name, present: @seo_validation.present, validation_type: @seo_validation.validation_type, value: @seo_validation.value }
    assert_redirected_to seo_validation_path(assigns(:seo_validation))
  end

  test "should destroy seo_validation" do
    assert_difference('SeoValidation.count', -1) do
      delete :destroy, id: @seo_validation
    end

    assert_redirected_to seo_validations_path
  end
end
