require 'test_helper'

class DevolucionesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get show" do
    get :show
    assert_response :success
  end

  test "should get consultaVenta" do
    get :consultaVenta
    assert_response :success
  end

end
