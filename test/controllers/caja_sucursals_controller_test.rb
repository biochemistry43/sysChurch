require 'test_helper'

class CajaSucursalsControllerTest < ActionController::TestCase
  setup do
    @caja_sucursal = caja_sucursals(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:caja_sucursals)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create caja_sucursal" do
    assert_difference('CajaSucursal.count') do
      post :create, caja_sucursal: { nombre: @caja_sucursal.nombre, numero_caja: @caja_sucursal.numero_caja, sucursal_id: @caja_sucursal.sucursal_id }
    end

    assert_redirected_to caja_sucursal_path(assigns(:caja_sucursal))
  end

  test "should show caja_sucursal" do
    get :show, id: @caja_sucursal
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @caja_sucursal
    assert_response :success
  end

  test "should update caja_sucursal" do
    patch :update, id: @caja_sucursal, caja_sucursal: { nombre: @caja_sucursal.nombre, numero_caja: @caja_sucursal.numero_caja, sucursal_id: @caja_sucursal.sucursal_id }
    assert_redirected_to caja_sucursal_path(assigns(:caja_sucursal))
  end

  test "should destroy caja_sucursal" do
    assert_difference('CajaSucursal.count', -1) do
      delete :destroy, id: @caja_sucursal
    end

    assert_redirected_to caja_sucursals_path
  end
end
