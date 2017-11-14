require 'test_helper'

class PageIdentifiersControllerTest < ActionController::TestCase
  setup do
    @page_identifier = page_identifiers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:page_identifiers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create page_identifier" do
    assert_difference('PageIdentifier.count') do
      post :create, page_identifier: { page: @page_identifier.page, value: @page_identifier.value }
    end

    assert_redirected_to page_identifier_path(assigns(:page_identifier))
  end

  test "should show page_identifier" do
    get :show, id: @page_identifier
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @page_identifier
    assert_response :success
  end

  test "should update page_identifier" do
    patch :update, id: @page_identifier, page_identifier: { page: @page_identifier.page, value: @page_identifier.value }
    assert_redirected_to page_identifier_path(assigns(:page_identifier))
  end

  test "should destroy page_identifier" do
    assert_difference('PageIdentifier.count', -1) do
      delete :destroy, id: @page_identifier
    end

    assert_redirected_to page_identifiers_path
  end
end
