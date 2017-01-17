require 'test_helper'

class BancosControllerTest < ActionController::TestCase
  setup do
    @banco = bancos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bancos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create banco" do
    assert_difference('Banco.count') do
      post :create, banco: { descripcion: @banco.descripcion, fecha: @banco.fecha, nombreCuenta: @banco.nombreCuenta, numeroCuenta: @banco.numeroCuenta, saldoInicial: @banco.saldoInicial, tipoCuenta: @banco.tipoCuenta }
    end

    assert_redirected_to banco_path(assigns(:banco))
  end

  test "should show banco" do
    get :show, id: @banco
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @banco
    assert_response :success
  end

  test "should update banco" do
    patch :update, id: @banco, banco: { descripcion: @banco.descripcion, fecha: @banco.fecha, nombreCuenta: @banco.nombreCuenta, numeroCuenta: @banco.numeroCuenta, saldoInicial: @banco.saldoInicial, tipoCuenta: @banco.tipoCuenta }
    assert_redirected_to banco_path(assigns(:banco))
  end

  test "should destroy banco" do
    assert_difference('Banco.count', -1) do
      delete :destroy, id: @banco
    end

    assert_redirected_to bancos_path
  end
end
