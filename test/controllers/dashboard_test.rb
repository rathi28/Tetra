require "minitest/autorun"
require 'pry'

class DashboardControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:headertext)
    assert_not_nil assigns(:buyflow)
    assert_not_nil assigns(:offercode)
  end

  test "admin needs login" do
    get :admin_dash
    assert_response 302
    assert_equal flash[:warning], "Not Logged In"
  end
end