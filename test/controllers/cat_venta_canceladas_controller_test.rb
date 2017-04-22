require 'test_helper'

class CatVentaCanceladasControllerTest < ActionController::TestCase
  setup do
    @cat_venta_cancelada = cat_venta_canceladas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cat_venta_canceladas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cat_venta_cancelada" do
    assert_difference('CatVentaCancelada.count') do
      post :create, cat_venta_cancelada: { clave: @cat_venta_cancelada.clave, descripcion: @cat_venta_cancelada.descripcion }
    end

    assert_redirected_to cat_venta_cancelada_path(assigns(:cat_venta_cancelada))
  end

  test "should show cat_venta_cancelada" do
    get :show, id: @cat_venta_cancelada
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @cat_venta_cancelada
    assert_response :success
  end

  test "should update cat_venta_cancelada" do
    patch :update, id: @cat_venta_cancelada, cat_venta_cancelada: { clave: @cat_venta_cancelada.clave, descripcion: @cat_venta_cancelada.descripcion }
    assert_redirected_to cat_venta_cancelada_path(assigns(:cat_venta_cancelada))
  end

  test "should destroy cat_venta_cancelada" do
    assert_difference('CatVentaCancelada.count', -1) do
      delete :destroy, id: @cat_venta_cancelada
    end

    assert_redirected_to cat_venta_canceladas_path
  end
end
