require 'test_helper'

class SucursalsControllerTest < ActionController::TestCase
  setup do
    @sucursal = sucursals(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sucursals)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sucursal" do
    assert_difference('Sucursal.count') do
      post :create, sucursal: { direccion: @sucursal.direccion, negocio_id: @sucursal.negocio_id, nombre: @sucursal.nombre, representante: @sucursal.representante }
    end

    assert_redirected_to sucursal_path(assigns(:sucursal))
  end

  test "should show sucursal" do
    get :show, id: @sucursal
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sucursal
    assert_response :success
  end

  test "should update sucursal" do
    patch :update, id: @sucursal, sucursal: { direccion: @sucursal.direccion, negocio_id: @sucursal.negocio_id, nombre: @sucursal.nombre, representante: @sucursal.representante }
    assert_redirected_to sucursal_path(assigns(:sucursal))
  end

  test "should destroy sucursal" do
    assert_difference('Sucursal.count', -1) do
      delete :destroy, id: @sucursal
    end

    assert_redirected_to sucursals_path
  end
end
