require 'test_helper'

class ClaveProdServsControllerTest < ActionController::TestCase
  setup do
    @clave_prod_serv = clave_prod_servs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:clave_prod_servs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create clave_prod_serv" do
    assert_difference('ClaveProdServ.count') do
      post :create, clave_prod_serv: { clave: @clave_prod_serv.clave, nombre: @clave_prod_serv.nombre }
    end

    assert_redirected_to clave_prod_serv_path(assigns(:clave_prod_serv))
  end

  test "should show clave_prod_serv" do
    get :show, id: @clave_prod_serv
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @clave_prod_serv
    assert_response :success
  end

  test "should update clave_prod_serv" do
    patch :update, id: @clave_prod_serv, clave_prod_serv: { clave: @clave_prod_serv.clave, nombre: @clave_prod_serv.nombre }
    assert_redirected_to clave_prod_serv_path(assigns(:clave_prod_serv))
  end

  test "should destroy clave_prod_serv" do
    assert_difference('ClaveProdServ.count', -1) do
      delete :destroy, id: @clave_prod_serv
    end

    assert_redirected_to clave_prod_servs_path
  end
end
