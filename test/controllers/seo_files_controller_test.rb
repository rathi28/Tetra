require 'test_helper'

class SeoFilesControllerTest < ActionController::TestCase
  setup do
    @seo_file = seo_files(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:seo_files)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create seo_file" do
    assert_difference('SeoFile.count') do
      post :create, seo_file: { domain: @seo_file.domain, filename: @seo_file.filename, targeturl: @seo_file.targeturl, valid_content: @seo_file.valid_content }
    end

    assert_redirected_to seo_file_path(assigns(:seo_file))
  end

  test "should show seo_file" do
    get :show, id: @seo_file
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @seo_file
    assert_response :success
  end

  test "should update seo_file" do
    patch :update, id: @seo_file, seo_file: { domain: @seo_file.domain, filename: @seo_file.filename, targeturl: @seo_file.targeturl, valid_content: @seo_file.valid_content }
    assert_redirected_to seo_file_path(assigns(:seo_file))
  end

  test "should destroy seo_file" do
    assert_difference('SeoFile.count', -1) do
      delete :destroy, id: @seo_file
    end

    assert_redirected_to seo_files_path
  end
end
