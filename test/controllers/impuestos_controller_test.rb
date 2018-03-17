require 'test_helper'

class ImpuestosControllerTest < ActionController::TestCase
  setup do
    @impuesto = impuestos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:impuestos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create impuesto" do
    assert_difference('Impuesto.count') do
      post :create, impuesto: { descripcion: @impuesto.descripcion, nombre: @impuesto.nombre, porcentaje: @impuesto.porcentaje, tipo: @impuesto.tipo }
    end

    assert_redirected_to impuesto_path(assigns(:impuesto))
  end

  test "should show impuesto" do
    get :show, id: @impuesto
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @impuesto
    assert_response :success
  end

  test "should update impuesto" do
    patch :update, id: @impuesto, impuesto: { descripcion: @impuesto.descripcion, nombre: @impuesto.nombre, porcentaje: @impuesto.porcentaje, tipo: @impuesto.tipo }
    assert_redirected_to impuesto_path(assigns(:impuesto))
  end

  test "should destroy impuesto" do
    assert_difference('Impuesto.count', -1) do
      delete :destroy, id: @impuesto
    end

    assert_redirected_to impuestos_path
  end
end
