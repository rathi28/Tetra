require 'test_helper'

class TestrunsControllerTest < ActionController::TestCase
  setup do
    login_to_tetra
  end
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get show" do
    get :index, {:id => 4083}
    assert_response :success
  end

  test "should get new buyflow page" do
    get :new, :type => 'buyflow'
    assert_response :success
  end

  test "should get new offercode page" do
    get :new, :type => 'offercode'
    assert_response :success
  end
end
