require 'test_helper'
require 'pry'
class WorkersControllerTest < ActionController::TestCase
  setup do
    login_to_tetra
    @worker = workers(:one)
  end

  test "should get index" do
    
    get :index
    assert_response :success
    assert_not_nil assigns(:workers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create worker" do
    assert_difference('Worker.count') do
      post :create, worker: { buyflow: @worker.buyflow, ip: @worker.ip, name: @worker.name, offercode: @worker.offercode, pixel: @worker.pixel, scheduled: @worker.scheduled }
    end

    assert_redirected_to worker_path(assigns(:worker))
  end

  test "should show worker" do
    get :show, id: @worker
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @worker
    assert_response :success
  end

  test "should update worker" do
    patch :update, id: @worker, worker: { buyflow: @worker.buyflow, ip: @worker.ip, name: @worker.name, offercode: @worker.offercode, pixel: @worker.pixel, scheduled: @worker.scheduled }
    assert_redirected_to worker_path(assigns(:worker))
  end

  test "should destroy worker" do
    assert_difference('Worker.count', -1) do
      delete :destroy, id: @worker
    end

    assert_redirected_to workers_path
  end
end
