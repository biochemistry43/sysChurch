require 'test_helper'

class PresentacionProductosControllerTest < ActionController::TestCase
  setup do
    @presentacion_producto = presentacion_productos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:presentacion_productos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create presentacion_producto" do
    assert_difference('PresentacionProducto.count') do
      post :create, presentacion_producto: { nombre: @presentacion_producto.nombre }
    end

    assert_redirected_to presentacion_producto_path(assigns(:presentacion_producto))
  end

  test "should show presentacion_producto" do
    get :show, id: @presentacion_producto
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @presentacion_producto
    assert_response :success
  end

  test "should update presentacion_producto" do
    patch :update, id: @presentacion_producto, presentacion_producto: { nombre: @presentacion_producto.nombre }
    assert_redirected_to presentacion_producto_path(assigns(:presentacion_producto))
  end

  test "should destroy presentacion_producto" do
    assert_difference('PresentacionProducto.count', -1) do
      delete :destroy, id: @presentacion_producto
    end

    assert_redirected_to presentacion_productos_path
  end
end
