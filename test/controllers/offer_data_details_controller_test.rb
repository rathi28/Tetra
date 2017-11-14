require 'test_helper'

class OfferDataDetailsControllerTest < ActionController::TestCase
  setup do
    @offer_data_detail = offer_data_details(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:offer_data_details)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create offer_data_detail" do
    assert_difference('OfferDataDetail.count') do
      post :create, offer_data_detail: { offer_title: @offer_data_detail.offer_title, offerdatum_id: @offer_data_detail.offerdatum_id, offerdesc: @offer_data_detail.offerdesc }
    end

    assert_redirected_to offer_data_detail_path(assigns(:offer_data_detail))
  end

  test "should show offer_data_detail" do
    get :show, id: @offer_data_detail
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @offer_data_detail
    assert_response :success
  end

  test "should update offer_data_detail" do
    patch :update, id: @offer_data_detail, offer_data_detail: { offer_title: @offer_data_detail.offer_title, offerdatum_id: @offer_data_detail.offerdatum_id, offerdesc: @offer_data_detail.offerdesc }
    assert_redirected_to offer_data_detail_path(assigns(:offer_data_detail))
  end

  test "should destroy offer_data_detail" do
    assert_difference('OfferDataDetail.count', -1) do
      delete :destroy, id: @offer_data_detail
    end

    assert_redirected_to offer_data_details_path
  end
end
