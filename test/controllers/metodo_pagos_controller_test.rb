require 'test_helper'

class MetodoPagosControllerTest < ActionController::TestCase
  setup do
    @metodo_pago = metodo_pagos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:metodo_pagos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create metodo_pago" do
    assert_difference('MetodoPago.count') do
      post :create, metodo_pago: { clave: @metodo_pago.clave, descripcion: @metodo_pago.descripcion }
    end

    assert_redirected_to metodo_pago_path(assigns(:metodo_pago))
  end

  test "should show metodo_pago" do
    get :show, id: @metodo_pago
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @metodo_pago
    assert_response :success
  end

  test "should update metodo_pago" do
    patch :update, id: @metodo_pago, metodo_pago: { clave: @metodo_pago.clave, descripcion: @metodo_pago.descripcion }
    assert_redirected_to metodo_pago_path(assigns(:metodo_pago))
  end

  test "should destroy metodo_pago" do
    assert_difference('MetodoPago.count', -1) do
      delete :destroy, id: @metodo_pago
    end

    assert_redirected_to metodo_pagos_path
  end
end
