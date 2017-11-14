require 'test_helper'

class ScheduleControllerTest < ActionController::TestCase
  
  # Tests with Authentication
  test "should get index" do
    login_to_tetra
    get :index
    assert_response :success
    assert_not_nil assigns(:testruns)
    assert_not_nil assigns(:recurring_tests)
  end

  test "should get new scheduled test page" do
    login_to_tetra
    get :new
    assert_response :success
    assert_not_nil assigns(:brands)
    assert_not_nil assigns(:browsers)
    assert_not_nil assigns(:default_email)
  end

  test "should get a recurring test edit page" do
    login_to_tetra
    get :edit, {:id => 1}
    assert_not_nil assigns(:test)
    assert_response :success
  end

  test "should be able to disable test" do
    login_to_tetra
    schedule = RecurringSchedule.find(2)
    post :disable, {:id => 2}
    assert_response :redirect
    schedule = RecurringSchedule.find(2)
    assert_nil schedule.active
  end

  test "should be able to delete test" do
    login_to_tetra
    delete :delete, {:id => 1}
    assert_response :redirect
  end

  # Tests without Authentication
  test "shouldn't get index" do
    
    get :index
    assert_response :redirect
    # assert_not_nil assigns(:testruns)
    assert_nil assigns(:recurring_tests)
  end

  test "shouldn't get new scheduled test page" do
    
    get :new
    assert_response :redirect
    assert_nil assigns(:brands)
    assert_nil assigns(:browsers)
    assert_nil assigns(:default_email)
  end

  test "shouldn't get a recurring test edit page" do
    
    get :edit, {:id => 1}
    #assert_not_nil assigns(:test)
    assert_response :redirect
  end
end
